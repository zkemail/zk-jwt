import path from "path";
import { wasm as wasm_tester } from "circom_tester";
const relayerUtils = require("@zk-email/relayer-utils");
import {
    generateJWTVerifierInputs,
    RSAPublicKey,
} from "../../helpers/src/input-generators";
import { generateJWT } from "../../helpers/src/jwt";
import { splitJWT } from "../../helpers/src/utils";
import fs from "fs";

describe("JWT Verifier Circuit", () => {
    jest.setTimeout(10 * 60 * 1000); // 10 minutes

    let circuit: any;
    let header: any;
    let payload: any;
    let accountCode: bigint;
    let timestamp: number;
    let issuer: string;
    let azp: string;
    let email: string;
    let kid: bigint;

    beforeAll(async () => {
        circuit = await wasm_tester(
            path.join(__dirname, "./test-circuits/jwt-verifier-test.circom"),
            {
                recompile: false,
                include: path.join(__dirname, "../../../node_modules"),
                output: path.join(__dirname, "./compiled-test-circuits"),
            }
        );

        accountCode = await relayerUtils.genAccountCode();

        kid = BigInt("0x5aaff47c21d06e266cce395b2145c7c6d4730ea5");
        issuer = "random.website.com";
        timestamp = 1694989812;
        azp = "demo-client-id";
        email = "dummy@gmail.com";

        header = {
            alg: "RS256",
            typ: "JWT",
            kid: kid.toString(16),
        };

        payload = {
            email,
            iat: timestamp,
            azp,
            iss: issuer,
        };
    });

    it("Verify a jwt whose command has an email address", async () => {
        const { rawJWT, publicKey } = generateJWT(header, {
            ...payload,
            nonce: "Send 0.1 ETH to alice@gmail.com",
        });

        const jwtVerifierInputs = await generateJWTVerifierInputs(
            rawJWT,
            publicKey,
            accountCode,
            {
                maxMessageLength: 1024,
            }
        );

        const witness = await circuit.calculateWitness(jwtVerifierInputs);
        await circuit.checkConstraints(witness);

        // kid
        expect(BigInt(kid)).toEqual(witness[1]);

        // issuer
        const paddedIssuer = relayerUtils.padString(issuer, 32);
        const issuerFields = relayerUtils.bytes2Fields(paddedIssuer);
        for (let i = 0; i < issuerFields.length; i++) {
            expect(BigInt(issuerFields[i])).toEqual(witness[1 + 1 + i]);
        }

        // publicKeyHash
        const expectedPubKeyHash = relayerUtils.publicKeyHash(
            "0x" + Buffer.from(publicKey.n, "base64").toString("hex")
        );
        expect(BigInt(expectedPubKeyHash)).toEqual(
            witness[1 + 1 + issuerFields.length]
        );

        // jwtNullifier
        const [, , signature] = splitJWT(rawJWT);
        const expectedJwtNullifier = relayerUtils.emailNullifier(
            "0x" + Buffer.from(signature, "base64").toString("hex")
        );
        expect(BigInt(expectedJwtNullifier)).toEqual(
            witness[1 + 1 + issuerFields.length + 1]
        );

        // timestamp
        expect(timestamp).toEqual(
            parseInt(witness[1 + 1 + issuerFields.length + 2])
        );

        // maskedCommand
        const maskedCommand = "Send 0.1 ETH to ";
        const paddedMaskedCommand = relayerUtils.padString(maskedCommand, 605);
        const maskedCommandFields =
            relayerUtils.bytes2Fields(paddedMaskedCommand);
        for (let i = 0; i < maskedCommandFields.length; ++i) {
            expect(BigInt(maskedCommandFields[i])).toEqual(
                witness[1 + 1 + issuerFields.length + 3 + i]
            );
        }

        // accountSalt
        const accountSalt = relayerUtils.accountSalt(email, accountCode);
        expect(BigInt(accountSalt)).toEqual(
            witness[
                1 + 1 + issuerFields.length + 3 + maskedCommandFields.length
            ]
        );

        // azp
        const paddedAzp = relayerUtils.padString(azp, 72);
        const azpFields = relayerUtils.bytes2Fields(paddedAzp);
        for (let i = 0; i < azpFields.length; i++) {
            expect(BigInt(azpFields[i])).toEqual(
                witness[
                    1 +
                        1 +
                        issuerFields.length +
                        3 +
                        maskedCommandFields.length +
                        1 +
                        i
                ]
            );
        }

        // isCodeExist
        expect(0n).toEqual(
            witness[
                1 +
                    1 +
                    issuerFields.length +
                    3 +
                    maskedCommandFields.length +
                    1 +
                    azpFields.length
            ]
        );
    });

    it("Verify a jwt whose command does not have an email address", async () => {
        const { rawJWT, publicKey } = generateJWT(header, {
            ...payload,
            nonce: "Swap 1 ETH to DAI",
        });

        const jwtVerifierInputs = await generateJWTVerifierInputs(
            rawJWT,
            publicKey,
            accountCode,
            {
                maxMessageLength: 1024,
            }
        );

        const witness = await circuit.calculateWitness(jwtVerifierInputs);
        await circuit.checkConstraints(witness);

        // kid
        expect(BigInt(kid)).toEqual(witness[1]);

        // issuer
        const paddedIssuer = relayerUtils.padString(issuer, 32);
        const issuerFields = relayerUtils.bytes2Fields(paddedIssuer);
        for (let i = 0; i < issuerFields.length; i++) {
            expect(BigInt(issuerFields[i])).toEqual(witness[1 + 1 + i]);
        }

        // publicKeyHash
        const expectedPubKeyHash = relayerUtils.publicKeyHash(
            "0x" + Buffer.from(publicKey.n, "base64").toString("hex")
        );
        expect(BigInt(expectedPubKeyHash)).toEqual(
            witness[1 + 1 + issuerFields.length]
        );

        // jwtNullifier
        const [, , signature] = splitJWT(rawJWT);
        const expectedJwtNullifier = relayerUtils.emailNullifier(
            "0x" + Buffer.from(signature, "base64").toString("hex")
        );
        expect(BigInt(expectedJwtNullifier)).toEqual(
            witness[1 + 1 + issuerFields.length + 1]
        );

        // timestamp
        expect(timestamp).toEqual(
            parseInt(witness[1 + 1 + issuerFields.length + 2])
        );

        // maskedCommand
        const maskedCommand = "Swap 1 ETH to DAI";
        const paddedMaskedCommand = relayerUtils.padString(maskedCommand, 605);
        const maskedCommandFields =
            relayerUtils.bytes2Fields(paddedMaskedCommand);
        for (let i = 0; i < maskedCommandFields.length; ++i) {
            expect(BigInt(maskedCommandFields[i])).toEqual(
                witness[1 + 1 + issuerFields.length + 3 + i]
            );
        }

        // accountSalt
        const accountSalt = relayerUtils.accountSalt(email, accountCode);
        expect(BigInt(accountSalt)).toEqual(
            witness[
                1 + 1 + issuerFields.length + 3 + maskedCommandFields.length
            ]
        );

        // azp
        const paddedAzp = relayerUtils.padString(azp, 72);
        const azpFields = relayerUtils.bytes2Fields(paddedAzp);
        for (let i = 0; i < azpFields.length; i++) {
            expect(BigInt(azpFields[i])).toEqual(
                witness[
                    1 +
                        1 +
                        issuerFields.length +
                        3 +
                        maskedCommandFields.length +
                        1 +
                        i
                ]
            );
        }

        // isCodeExist
        expect(0n).toEqual(
            witness[
                1 +
                    1 +
                    issuerFields.length +
                    3 +
                    maskedCommandFields.length +
                    1 +
                    azpFields.length
            ]
        );
    });

    it("Verify a jwt whose command has an email address and an invitation code", async () => {
        const { rawJWT, publicKey } = generateJWT(header, {
            ...payload,
            nonce: `Send 0.12 ETH to alice@gmail.com code ${accountCode
                .toString(16)
                .slice(2)}`,
        });

        const jwtVerifierInputs = await generateJWTVerifierInputs(
            rawJWT,
            publicKey,
            accountCode,
            {
                maxMessageLength: 1024,
            }
        );

        const witness = await circuit.calculateWitness(jwtVerifierInputs);
        await circuit.checkConstraints(witness);

        // kid
        expect(BigInt(kid)).toEqual(witness[1]);

        // issuer
        const paddedIssuer = relayerUtils.padString(issuer, 32);
        const issuerFields = relayerUtils.bytes2Fields(paddedIssuer);
        for (let i = 0; i < issuerFields.length; i++) {
            expect(BigInt(issuerFields[i])).toEqual(witness[1 + 1 + i]);
        }

        // publicKeyHash
        const expectedPubKeyHash = relayerUtils.publicKeyHash(
            "0x" + Buffer.from(publicKey.n, "base64").toString("hex")
        );
        expect(BigInt(expectedPubKeyHash)).toEqual(
            witness[1 + 1 + issuerFields.length]
        );

        // jwtNullifier
        const [, , signature] = splitJWT(rawJWT);
        const expectedJwtNullifier = relayerUtils.emailNullifier(
            "0x" + Buffer.from(signature, "base64").toString("hex")
        );
        expect(BigInt(expectedJwtNullifier)).toEqual(
            witness[1 + 1 + issuerFields.length + 1]
        );

        // timestamp
        expect(timestamp).toEqual(
            parseInt(witness[1 + 1 + issuerFields.length + 2])
        );

        // maskedCommand
        const maskedCommand = "Send 0.12 ETH to ";
        const paddedMaskedCommand = relayerUtils.padString(maskedCommand, 605);
        const maskedCommandFields =
            relayerUtils.bytes2Fields(paddedMaskedCommand);
        for (let i = 0; i < maskedCommandFields.length; ++i) {
            expect(BigInt(maskedCommandFields[i])).toEqual(
                witness[1 + 1 + issuerFields.length + 3 + i]
            );
        }

        // accountSalt
        const accountSalt = relayerUtils.accountSalt(email, accountCode);
        expect(BigInt(accountSalt)).toEqual(
            witness[
                1 + 1 + issuerFields.length + 3 + maskedCommandFields.length
            ]
        );

        // azp
        const paddedAzp = relayerUtils.padString(azp, 72);
        const azpFields = relayerUtils.bytes2Fields(paddedAzp);
        for (let i = 0; i < azpFields.length; i++) {
            expect(BigInt(azpFields[i])).toEqual(
                witness[
                    1 +
                        1 +
                        issuerFields.length +
                        3 +
                        maskedCommandFields.length +
                        1 +
                        i
                ]
            );
        }

        // isCodeExist
        expect(1n).toEqual(
            witness[
                1 +
                    1 +
                    issuerFields.length +
                    3 +
                    maskedCommandFields.length +
                    1 +
                    azpFields.length
            ]
        );
    });

    it("Verify a jwt whose command has an invitation code", async () => {
        const { rawJWT, publicKey } = generateJWT(header, {
            ...payload,
            nonce: `Re: Accept guardian request for 0x04884491560f38342C56E26BDD0fEAbb68E2d2FC code ${accountCode
                .toString(16)
                .slice(2)}`,
        });

        const jwtVerifierInputs = await generateJWTVerifierInputs(
            rawJWT,
            publicKey,
            accountCode,
            {
                maxMessageLength: 1024,
            }
        );

        const witness = await circuit.calculateWitness(jwtVerifierInputs);
        await circuit.checkConstraints(witness);

        // kid
        expect(BigInt(kid)).toEqual(witness[1]);

        // issuer
        const paddedIssuer = relayerUtils.padString(issuer, 32);
        const issuerFields = relayerUtils.bytes2Fields(paddedIssuer);
        for (let i = 0; i < issuerFields.length; i++) {
            expect(BigInt(issuerFields[i])).toEqual(witness[1 + 1 + i]);
        }

        // publicKeyHash
        const expectedPubKeyHash = relayerUtils.publicKeyHash(
            "0x" + Buffer.from(publicKey.n, "base64").toString("hex")
        );
        expect(BigInt(expectedPubKeyHash)).toEqual(
            witness[1 + 1 + issuerFields.length]
        );

        // jwtNullifier
        const [, , signature] = splitJWT(rawJWT);
        const expectedJwtNullifier = relayerUtils.emailNullifier(
            "0x" + Buffer.from(signature, "base64").toString("hex")
        );
        expect(BigInt(expectedJwtNullifier)).toEqual(
            witness[1 + 1 + issuerFields.length + 1]
        );

        // timestamp
        expect(timestamp).toEqual(
            parseInt(witness[1 + 1 + issuerFields.length + 2])
        );

        // maskedCommand
        const maskedCommand =
            "Re: Accept guardian request for 0x04884491560f38342C56E26BDD0fEAbb68E2d2FC";
        const paddedMaskedCommand = relayerUtils.padString(maskedCommand, 605);
        const maskedCommandFields =
            relayerUtils.bytes2Fields(paddedMaskedCommand);
        for (let i = 0; i < maskedCommandFields.length; ++i) {
            expect(BigInt(maskedCommandFields[i])).toEqual(
                witness[1 + 1 + issuerFields.length + 3 + i]
            );
        }

        // accountSalt
        const accountSalt = relayerUtils.accountSalt(email, accountCode);
        expect(BigInt(accountSalt)).toEqual(
            witness[
                1 + 1 + issuerFields.length + 3 + maskedCommandFields.length
            ]
        );

        // azp
        const paddedAzp = relayerUtils.padString(azp, 72);
        const azpFields = relayerUtils.bytes2Fields(paddedAzp);
        for (let i = 0; i < azpFields.length; i++) {
            expect(BigInt(azpFields[i])).toEqual(
                witness[
                    1 +
                        1 +
                        issuerFields.length +
                        3 +
                        maskedCommandFields.length +
                        1 +
                        i
                ]
            );
        }

        // isCodeExist
        expect(1n).toEqual(
            witness[
                1 +
                    1 +
                    issuerFields.length +
                    3 +
                    maskedCommandFields.length +
                    1 +
                    azpFields.length
            ]
        );
    });

    // @Note - Needs an actual Google Sign-In JWT to run
    it("Verify a real Google Sign-In JWT", async () => {
        const googleSignInData = JSON.parse(
            fs.readFileSync(
                path.join(__dirname, "test-jwts/google-sign-in.json"),
                "utf8"
            )
        );
        const rawJWT = googleSignInData.idToken;
        const publicKey: RSAPublicKey = {
            e: 65537,
            n: googleSignInData.publicKeys.keys[1].n,
        };

        const jwtVerifierInputs = await generateJWTVerifierInputs(
            rawJWT,
            publicKey,
            accountCode,
            {
                maxMessageLength: 1024,
            }
        );

        const witness = await circuit.calculateWitness(jwtVerifierInputs);
        await circuit.checkConstraints(witness);

        const [header, payload, signature] = splitJWT(rawJWT);
        const decodedPayload = JSON.parse(
            Buffer.from(payload, "base64").toString()
        );

        // kid
        const expectedKid = BigInt(
            "0x" + googleSignInData.publicKeys.keys[1].kid
        );
        expect(expectedKid).toEqual(witness[1]);

        // issuer
        const paddedIssuer = relayerUtils.padString(decodedPayload.iss, 32);
        const issuerFields = relayerUtils.bytes2Fields(paddedIssuer);
        for (let i = 0; i < issuerFields.length; i++) {
            expect(BigInt(issuerFields[i])).toEqual(witness[1 + 1 + i]);
        }
        console.log("iss length", issuerFields.length);

        // publicKeyHash
        const expectedPubKeyHash = relayerUtils.publicKeyHash(
            "0x" + Buffer.from(publicKey.n, "base64").toString("hex")
        );
        expect(BigInt(expectedPubKeyHash)).toEqual(
            witness[1 + 1 + issuerFields.length]
        );

        // jwtNullifier
        const expectedJwtNullifier = relayerUtils.emailNullifier(
            "0x" + Buffer.from(signature, "base64").toString("hex")
        );
        expect(BigInt(expectedJwtNullifier)).toEqual(
            witness[1 + 1 + issuerFields.length + 1]
        );

        // timestamp
        expect(decodedPayload.iat).toEqual(
            parseInt(witness[1 + 1 + issuerFields.length + 2])
        );

        // maskedCommand (in this case, there's no command, so it should be empty)
        const maskedCommand = "Swap 1 ETH to DAI";
        const paddedMaskedCommand = relayerUtils.padString(maskedCommand, 605);
        const maskedCommandFields =
            relayerUtils.bytes2Fields(paddedMaskedCommand);
        for (let i = 0; i < maskedCommandFields.length; ++i) {
            expect(BigInt(maskedCommandFields[i])).toEqual(
                witness[1 + 1 + issuerFields.length + 3 + i]
            );
        }
        console.log("maskedCommand length", maskedCommandFields.length);

        // accountSalt
        const accountSalt = relayerUtils.accountSalt(
            decodedPayload.email,
            accountCode
        );
        expect(BigInt(accountSalt)).toEqual(
            witness[
                1 + 1 + issuerFields.length + 3 + maskedCommandFields.length
            ]
        );

        // azp
        const paddedAzp = relayerUtils.padString(decodedPayload.azp, 72);
        const azpFields = relayerUtils.bytes2Fields(paddedAzp);
        for (let i = 0; i < azpFields.length; i++) {
            expect(BigInt(azpFields[i])).toEqual(
                witness[
                    1 +
                        1 +
                        issuerFields.length +
                        3 +
                        maskedCommandFields.length +
                        1 +
                        i
                ]
            );
        }
        console.log("azp length", azpFields.length);

        // isCodeExist (should be 0 as there's no invitation code in this JWT)
        expect(0n).toEqual(
            witness[
                1 +
                    1 +
                    issuerFields.length +
                    3 +
                    maskedCommandFields.length +
                    1 +
                    azpFields.length
            ]
        );
    });
});
