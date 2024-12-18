import wasm_tester from "circom_tester/wasm/tester";
import path from "path";
import { generateJWT } from "../../helpers/src/jwt";
import { generateJWTAuthenticatorInputs } from "../../helpers/src/input-generators";

describe("Teleport NFT Redeem Circuit", () => {
    jest.setTimeout(10 * 60 * 1000); // 10 minutes
    let circuit: any;
    let header: any;
    let payload: any;

    beforeAll(async () => {
        circuit = await wasm_tester(
            path.join(__dirname, "../examples/teleport-nft-redeem.circom"),
            {
                recompile: true,
                include: path.join(__dirname, "../../../node_modules"),
                output: path.join(__dirname, "./compiled-test-circuits"),
            }
        );

        header = {
            alg: "RS256",
            typ: "JWT",
            kid: "5aaff47c21d06e266cce395b2145c7c6d4730ea5",
        };

        payload = {
            aud: "397234807794-fh6mhl0jppgtt0ak5cgikhlesbe8f7si.apps.googleusercontent.com",
            azp: "397234807794-fh6mhl0jppgtt0ak5cgikhlesbe8f7si.apps.googleusercontent.com",
            email: "shryas.londhe@gmail.com",
            email_verified: true,
            exp: 1733221947,
            family_name: "Londhe",
            given_name: "Shreyas",
            iat: 1733218347,
            iss: "https://accounts.google.com",
            jti: "925321421a41d135b4619a2809d6545ccc368392",
            name: "Shreyas Londhe",
            nbf: 1733218047,
            nonce: "asdfghjkl",
            picture:
                "https://lh3.googleusercontent.com/a/ACg8ocLEfBS88uysDlR62qW_ysr-eH2UjKjX5RJ-NCq5CyUBIu3xOw=s96-c",
            sub: "118246532521560959480",
        };
    });

    it("should verify a teleport-nft-redeem JWT", async () => {
        const { rawJWT, publicKey } = generateJWT(header, payload);

        const verifierInputs = await generateJWTAuthenticatorInputs(
            rawJWT,
            publicKey,
            BigInt(1024),
            {
                maxMessageLength: 1024,
                exposeGoogleId: true,
            }
        );

        const {
            accountCode,
            codeIndex,
            iatKeyStartIndex,
            ...filteredCircuitInputs
        } = verifierInputs;

        const witness = await circuit.calculateWitness(filteredCircuitInputs);
        await circuit.checkConstraints(witness);
    });
});
