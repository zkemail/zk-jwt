import {
    Uint8ArrayToCharArray,
    toCircomBigIntBytes,
    sha256Pad,
} from "@zk-email/helpers";
import { verifyJWT } from "./jwt";
import { base64ToBigInt, splitJWT } from "./utils";
import { MAX_JWT_PADDED_BYTES } from "./constants";

export interface RSAPublicKey {
    n: string; // Base64-encoded modulus
    e: number;
}

type JWTInputGenerationArgs = {
    maxMessageLength?: number; // Max length of the JWT message including padding
};

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
    params: JWTInputGenerationArgs = {}
): Promise<{
    message: string[]; // JWT message (header + payload)
    messageLength: string; // Length of the JWT message
    pubkey: string[]; // RSA public key
    signature: string[]; // RSA signature
}> {
    // Split the JWT token into its components
    const [headerString, payloadString, signatureString] = splitJWT(rawJWT);

    // Verify the JWT signature
    const isVerified = await verifyJWT(rawJWT, publicKey);
    if (!isVerified) {
        throw new Error("JWT verification failed: Invalid signature.");
    }

    // Prepare the message for the circuit
    const message = Buffer.from(`${headerString}.${payloadString}`);
    const [messagePadded, messagePaddedLen] = sha256Pad(
        message,
        params.maxMessageLength || MAX_JWT_PADDED_BYTES
    );

    return {
        message: Uint8ArrayToCharArray(messagePadded),
        messageLength: messagePaddedLen.toString(),
        pubkey: toCircomBigIntBytes(base64ToBigInt(publicKey.n)),
        signature: toCircomBigIntBytes(base64ToBigInt(signatureString)),
    };
}
