// @ts-ignore
import { program } from 'commander';
import { generateJWT } from '../../helpers/src/jwt'; // Specify the path to the function that generates JWT
import { generateJWTAuthenticatorInputs, generateJWTVerifierInputs } from '../../helpers/src/input-generators'; // Specify the path to the function that generates inputs
import { splitJWT } from "../../helpers/src/utils";
import fs from "fs";
const snarkjs = require("snarkjs");
import { promisify } from "util";
import path from "path";
const relayerUtils = require("@zk-email/relayer-utils");
import https from 'https';

program
  .requiredOption(
    "--input-file <string>",
    "Path of a json file to write the generated input"
  )
  .requiredOption('-a, --account-code <string>', 'Account code as bigint string')
  .option('-h, --header <string>', 'JWT header as JSON string')
  .option('-p, --payload <string>', 'JWT payload as JSON string')
  .option('-m, --maxMessageLength <number>', 'Maximum message length', '1024')
  .option("--silent", "No console logs")
  .option("--prove", "Also generate proof");

program.parse(process.argv);

const options = program.opts();

function log(...message: any) {
  if (!options.silent) {
    console.log(...message);
  }
}

async function main() {
  const kid = BigInt("0x5aaff47c21d06e266cce395b2145c7c6d4730ea5");
  const issuer = "random.website.com";
  const timestamp = 1694989812;
  const azp = "demo-client-id";
  const email = "dummy@gmail.com";

  const defaultHeader = {
    alg: "RS256",
    typ: "JWT",
    kid: kid.toString(16),
  };
  const header = defaultHeader;
  const defaultPayload = {
    email,
    iat: timestamp,
    azp,
    iss: issuer,
  };
  const payload = defaultPayload;
  const accountCode = BigInt(options.accountCode);

  const { rawJWT, publicKey } = generateJWT(header, {
    ...payload,
    nonce: "Send 0.1 ETH to alice@gmail.com",
});
  const jwtVerifierInputs = await generateJWTAuthenticatorInputs(
    rawJWT,
    publicKey,
    accountCode,
    {
        maxMessageLength: 1024,
    }
  );

  console.log('JWT Verifier Inputs:', jwtVerifierInputs);

  const publicKeyHash = relayerUtils.publicKeyHash(
    "0x" + Buffer.from(publicKey.n, "base64").toString("hex")
  );
  console.log("publicKeyHash");
  console.log(publicKeyHash);
  const [, , signature] = splitJWT(rawJWT);
  const expectedJwtNullifier = relayerUtils.emailNullifier(
    "0x" + Buffer.from(signature, "base64").toString("hex")
  );
  console.log("expectedJwtNullifier");
  console.log(expectedJwtNullifier);

  if (!options.inputFile.endsWith(".json")) {
    throw new Error("--input file path arg must end with .json");
  }

  const processedInputs = convertBigIntFieldsToString(jwtVerifierInputs);

  await promisify(fs.writeFile)(options.inputFile, JSON.stringify(processedInputs, null, 2));

  log("Inputs written to", options.inputFile);

  if (options.prove) {
    const dir = path.dirname(options.inputFile);
    const { proof, publicSignals } = await snarkjs.groth16.fullProve(jwtVerifierInputs, path.join(dir, "jwt_auth.wasm"), path.join(dir, "jwt_auth.zkey"), console);
    await promisify(fs.writeFile)(path.join(dir, "jwt_auth_proof.json"), JSON.stringify(proof, null, 2));
    await promisify(fs.writeFile)(path.join(dir, "jwt_auth_public.json"), JSON.stringify(publicSignals, null, 2));
    log("✓ Proof for jwt auth circuit generated");

    // Load verification key
    const vKey = JSON.parse(fs.readFileSync(path.join(dir, "jwt_auth.vkey"), "utf8"));
    // Verify the proof
    const isValid = await snarkjs.groth16.verify(vKey, publicSignals, proof);
    console.log(`result = ${isValid}`);
  };



  process.exit(0);
}

function convertBigIntFieldsToString(obj: any): any {
  if (typeof obj === 'object' && obj !== null) {
    return Object.fromEntries(
      Object.entries(obj).map(([key, value]) => [
        key,
        typeof value === 'bigint' ? value.toString() : value
      ])
    );
  }
  return obj;
}

main().catch((err) => {
  console.error("Error generating inputs", err);
  process.exit(1);
});