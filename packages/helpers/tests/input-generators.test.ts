import NodeRSA from "node-rsa";
import { generateJWTVerifierInputs } from "../src/input-generators";
import { RSAPublicKey } from "../src/input-generators";
import { generateJWT } from "../src/jwt";

describe("Generate JWT Verifier Inputs", () => {
    let rawJWT: string;
    let publicKey: RSAPublicKey;

    beforeAll(async () => {
        const header = {
            alg: "RS256",
            typ: "JWT",
        };
        const payload = {
            sub: "1234567890",
            name: "John Doe",
            iat: Math.floor(Date.now() / 1000),
        };

        const { rawJWT: jwt, publicKey: key } = generateJWT(header, payload);
        rawJWT = jwt;
        publicKey = key;
    });

    it("should generate valid inputs for a JWT", async () => {
        const inputs = await generateJWTVerifierInputs(rawJWT, {
            n: publicKey.n,
            e: publicKey.e,
        } as RSAPublicKey);
        expect(inputs).toBeDefined();
        expect(inputs.message).toBeInstanceOf(Array);
        expect(inputs.messageLength).toBeDefined();
        expect(inputs.pubkey).toBeInstanceOf(Array);
        expect(inputs.signature).toBeInstanceOf(Array);
        expect(inputs.periodIndex).toBeDefined();
        expect(inputs.jwtTypStartIndex).toBeDefined();
        expect(inputs.jwtAlgStartIndex).toBeDefined();
    });

    it("should throw an error for an invalid JWT", async () => {
        await expect(
            generateJWTVerifierInputs("", {
                n: publicKey.n,
                e: publicKey.e,
            } as RSAPublicKey)
        ).rejects.toThrow(
            'Invalid JWT format. Expected 3 parts separated by "."'
        );
    });

    it("should throw an error for an invalid public key", async () => {
        const invalidPublicKey = { n: "invalid", e: 0 };
        await expect(
            generateJWTVerifierInputs(rawJWT, invalidPublicKey as RSAPublicKey)
        ).rejects.toThrow("Invalid key data");
    });
});
