import path from "path";
import { wasm as wasm_tester } from "circom_tester";
import {
    generateJWTVerifierInputs,
    RSAPublicKey,
} from "../../helpers/src/input-generators";
import { generateJWT } from "../../helpers/src/jwt";

describe("JWT Verifier Circuit", () => {
    jest.setTimeout(10 * 60 * 1000); // 10 minutes

    let circuit: any;
    let rawJWT: string;
    let publicKey: RSAPublicKey;

    beforeAll(async () => {
        circuit = await wasm_tester(
            path.join(__dirname, "./test-circuits/jwt-verifier-test.circom"),
            {
                recompile: true,
                include: path.join(__dirname, "../../../node_modules"),
                output: path.join(__dirname, "./compiled-test-circuits"),
            }
        );

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
        publicKey = {
            n: key.n,
            e: key.e,
        };
    });

    it("should verify a valid JWT", async () => {
        const jwtVerifierInputs = await generateJWTVerifierInputs(
            rawJWT,
            {
                n: publicKey.n,
                e: publicKey.e,
            },
            {
                maxMessageLength: 256,
            }
        );

        const witness = await circuit.calculateWitness(jwtVerifierInputs);
        await circuit.checkConstraints(witness);
    });
});
