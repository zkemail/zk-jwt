import {
    generateJWTVerifierInputs,
    RSAPublicKey,
} from "../src/input-generators";
import { generateJWT } from "../src/jwt";
import { InvalidInputError, JWTVerificationError } from "../src/errors";

describe("generateJWTVerifierInputs", () => {
    let validJWT: string;
    let validPublicKey: RSAPublicKey;
    let validAccountCode: bigint;

    beforeAll(() => {
        const header = {
            alg: "RS256",
            typ: "JWT",
            kid: "test-key-id",
        };
        const payload = {
            iss: "https://example.com",
            iat: Math.floor(Date.now() / 1000),
            azp: "client-123",
            email: "user@example.com",
            nonce: "Send 0.1 ETH to alice@example.com code 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
        };

        const { rawJWT, publicKey } = generateJWT(header, payload);
        validJWT = rawJWT;
        validPublicKey = publicKey;
        validAccountCode = BigInt(
            "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        );
    });

    it("should generate valid inputs for a valid JWT", async () => {
        const result = await generateJWTVerifierInputs(
            validJWT,
            validPublicKey,
            validAccountCode
        );

        expect(result).toBeDefined();
        expect(result.message).toBeInstanceOf(Array);
        expect(result.messageLength).toBeDefined();
        expect(result.pubkey).toBeInstanceOf(Array);
        expect(result.signature).toBeInstanceOf(Array);
        expect(result.accountCode).toBe(validAccountCode);
        expect(result.codeIndex).toBeDefined();
        expect(result.periodIndex).toBeDefined();
        expect(result.jwtTypStartIndex).toBeDefined();
        expect(result.jwtAlgStartIndex).toBeDefined();
        expect(result.jwtKidStartIndex).toBeDefined();
        expect(result.issKeyStartIndex).toBeDefined();
        expect(result.issLength).toBeDefined();
        expect(result.iatKeyStartIndex).toBeDefined();
        expect(result.azpKeyStartIndex).toBeDefined();
        expect(result.azpLength).toBeDefined();
        expect(result.emailKeyStartIndex).toBeDefined();
        expect(result.emailLength).toBeDefined();
        expect(result.nonceKeyStartIndex).toBeDefined();
        expect(result.commandLength).toBeDefined();
    });

    it("should throw InvalidInputError for empty JWT", async () => {
        await expect(
            generateJWTVerifierInputs("", validPublicKey, validAccountCode)
        ).rejects.toThrow(InvalidInputError);
    });

    it("should throw InvalidInputError for non-string JWT", async () => {
        await expect(
            generateJWTVerifierInputs(
                123 as any,
                validPublicKey,
                validAccountCode
            )
        ).rejects.toThrow(InvalidInputError);
    });

    it("should throw InvalidInputError for invalid public key", async () => {
        const invalidPublicKey = { n: "invalid", e: "invalid" } as any;
        await expect(
            generateJWTVerifierInputs(
                validJWT,
                invalidPublicKey,
                validAccountCode
            )
        ).rejects.toThrow(InvalidInputError);
    });

    it("should throw InvalidInputError for JWT with missing components", async () => {
        const invalidJWT = "header.payload";
        await expect(
            generateJWTVerifierInputs(
                invalidJWT,
                validPublicKey,
                validAccountCode
            )
        ).rejects.toThrow(InvalidInputError);
    });

    it("should throw JWTVerificationError for invalid signature", async () => {
        const tamperedJWT = validJWT.slice(0, -1) + "X";
        await expect(
            generateJWTVerifierInputs(
                tamperedJWT,
                validPublicKey,
                validAccountCode
            )
        ).rejects.toThrow(JWTVerificationError);
    });

    it("should handle JWT without optional fields", async () => {
        const minimalHeader = {
            alg: "RS256",
            typ: "JWT",
        };
        const minimalPayload = {
            iss: "https://minimal.com",
            iat: Math.floor(Date.now() / 1000),
            nonce: "minimal nonce",
        };

        const { rawJWT, publicKey } = generateJWT(
            minimalHeader,
            minimalPayload
        );
        const result = await generateJWTVerifierInputs(
            rawJWT,
            publicKey,
            validAccountCode
        );

        expect(result).toBeDefined();
        expect(result.azpLength).toBe("0");
        expect(result.emailLength).toBe("0");
    });

    it("should handle maximum message length", async () => {
        const result = await generateJWTVerifierInputs(
            validJWT,
            validPublicKey,
            validAccountCode,
            { maxMessageLength: 1000 }
        );
        expect(parseInt(result.messageLength)).toBeLessThanOrEqual(1000);
    });
});
