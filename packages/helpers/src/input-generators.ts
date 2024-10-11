import {
    Uint8ArrayToCharArray,
    toCircomBigIntBytes,
    sha256Pad,
} from "@zk-email/helpers";
import { verifyJWT } from "./jwt";
import { base64ToBigInt, splitJWT } from "./utils";
import { MAX_JWT_PADDED_BYTES } from "./constants";
import { InvalidInputError, JWTVerificationError } from "./errors";

export interface RSAPublicKey {
    n: string; // Base64-encoded modulus
    e: number;
}

type JWTInputGenerationArgs = {
    maxMessageLength?: number; // Max length of the JWT message including padding
};

function findCodeIndex(nonce: string | undefined, accountCode: bigint): number {
    if (!nonce) return 0;
    const index = nonce.indexOf(accountCode.toString(16).slice(2));
    return index >= 0 ? index : 0;
}

/**
 * @description Generate circuit inputs for the JWTVerifier circuit from a raw JWT token
 * @param rawJWT Full JWT token as a string
 * @param publicKey The RSA public key
 * @param params Arguments to control the input generation
 * @returns Circuit inputs for the JWTVerifier circuit
 * @throws Error if the JWT verification fails or if the input is invalid
 */
export async function generateJWTVerifierInputs(
    rawJWT: string,
    publicKey: RSAPublicKey,
    accountCode: bigint,
    params: JWTInputGenerationArgs = {}
): Promise<{
    message: string[]; // JWT message (header + payload)
    messageLength: string; // Length of the JWT message
    pubkey: string[]; // RSA public key
    signature: string[]; // RSA signature
    accountCode: bigint; // Account code
    codeIndex: string; // Index of the "invitation code" in the "command"
    periodIndex: string; // Index of the period in the JWT message
    jwtTypStartIndex: string; // Index of the "typ" in the JWT header
    jwtKidStartIndex: string; // Index of the "kid" in the JWT header
    issKeyStartIndex: string; // Index of the "iss" in the JWT payload
    issLength: string; // Length of the "iss" in the JWT payload
    iatKeyStartIndex: string; // Index of the "iat" in the JWT payload
    azpKeyStartIndex: string; // Index of the "azp" in the JWT payload
    azpLength: string; // Length of the "azp" in the JWT payload
    emailKeyStartIndex: string; // Index of the "email" key in the JWT payload
    emailLength: string; // Length of the "email" in the JWT payload
    nonceKeyStartIndex: string; // Index of the "nonce" key in the JWT payload
    commandLength: string; // Length of the "command" in the "nonce" key in the JWT payload
}> {
    try {
        // Input validation
        if (!rawJWT || typeof rawJWT !== "string") {
            throw new InvalidInputError(
                "Invalid JWT: Must be a non-empty string"
            );
        }
        if (
            !publicKey ||
            typeof publicKey.n !== "string" ||
            typeof publicKey.e !== "number"
        ) {
            throw new InvalidInputError("Invalid public key");
        }

        // Split the JWT token into its components
        const [headerString, payloadString, signatureString] = splitJWT(rawJWT);

        // Verify the JWT signature
        let isVerified;
        try {
            isVerified = await verifyJWT(rawJWT, publicKey);
        } catch (error: any) {
            throw new JWTVerificationError(
                `JWT verification failed: ${error.message}`
            );
        }
        if (!isVerified) {
            throw new JWTVerificationError(
                "JWT verification failed: Invalid signature"
            );
        }

        // Find the index of the period in the JWT message
        const periodIndex = rawJWT.indexOf(".");

        // Prepare the message for the circuit
        const message = Buffer.from(`${headerString}.${payloadString}`);
        const [messagePadded, messagePaddedLen] = sha256Pad(
            message,
            params.maxMessageLength || MAX_JWT_PADDED_BYTES
        );

        // Decode header and payload
        const header = Buffer.from(headerString, "base64").toString("utf-8");
        const payload = Buffer.from(payloadString, "base64").toString("utf-8");

        console.log("Header:", header);
        console.log("Payload:", payload);

        // Parse payload
        let parsedPayload;
        try {
            parsedPayload = JSON.parse(payload);
        } catch (error) {
            throw new InvalidInputError(
                "Invalid JWT payload: Not a valid JSON"
            );
        }

        // Find the starting indices of the required substrings
        const jwtTypStartIndex = header.indexOf('"typ":"JWT"');
        const jwtKidStartIndex = header.indexOf('"kid":');
        const issKeyStartIndex = payload.indexOf('"iss":');
        const iatKeyStartIndex = payload.indexOf('"iat":');
        const azpKeyStartIndex = payload.indexOf('"azp":');
        const emailKeyStartIndex = payload.indexOf('"email":');
        const nonceKeyStartIndex = payload.indexOf('"nonce":');

        const issLength = parsedPayload.iss?.length ?? 0;
        const azpLength = parsedPayload.azp?.length ?? 0;
        const emailLength = parsedPayload.email?.length ?? 0;
        const commandLength = parsedPayload.nonce?.length ?? 0;

        const codeIndex = findCodeIndex(parsedPayload.nonce, accountCode);

        return {
            message: Uint8ArrayToCharArray(messagePadded),
            messageLength: messagePaddedLen.toString(),
            pubkey: toCircomBigIntBytes(base64ToBigInt(publicKey.n)),
            signature: toCircomBigIntBytes(base64ToBigInt(signatureString)),
            accountCode,
            codeIndex: codeIndex.toString(),
            periodIndex: periodIndex.toString(),
            jwtTypStartIndex: jwtTypStartIndex.toString(),
            jwtKidStartIndex: jwtKidStartIndex.toString(),
            issKeyStartIndex: issKeyStartIndex.toString(),
            issLength: issLength.toString(),
            iatKeyStartIndex: iatKeyStartIndex.toString(),
            azpKeyStartIndex: azpKeyStartIndex.toString(),
            azpLength: azpLength.toString(),
            emailKeyStartIndex: emailKeyStartIndex.toString(),
            emailLength: emailLength.toString(),
            nonceKeyStartIndex: nonceKeyStartIndex.toString(),
            commandLength: commandLength.toString(),
        };
    } catch (error: any) {
        if (
            error instanceof JWTVerificationError ||
            error instanceof InvalidInputError
        ) {
            throw error;
        }
        throw new Error(
            `Unexpected error in generateJWTVerifierInputs: ${error.message}`
        );
    }
}
