// @ts-ignore
import { program } from 'commander';
import { generateJWT } from '../../helpers/src/jwt'; // JWTを生成する関数のパスを指定
import { generateJWTVerifierInputs } from '../../helpers/src/input-generators'; // 入力を生成する関数のパスを指定
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
  .requiredOption('-a, --accountCode <string>', 'Account code as bigint string')
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
  const maxMessageLength = parseInt(options.maxMessageLength, 1024);


  const { rawJWT, publicKey } = generateJWT(header, {
    ...payload,
    nonce: "Send 0.1 ETH to alice@gmail.com",
  });

  const jwtVerifierInputs = await generateJWTVerifierInputs(
    rawJWT,
    publicKey,
    accountCode,
    { maxMessageLength }
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

  // log("Generating Inputs for:", options);

  // const circuitInputs = await genEmailCircuitInput(args.emailFile, args.accountCode, {
  //     maxHeaderLength: 1024,
  //     ignoreBodyHashCheck: true
  // });
  // log("\n\nGenerated Inputs:", circuitInputs, "\n\n");
  const processedInputs = convertBigIntFieldsToString(jwtVerifierInputs);

  await promisify(fs.writeFile)(options.inputFile, JSON.stringify(processedInputs, null, 2));

  log("Inputs written to", options.inputFile);

  if (options.prove) {
    console.log("generate pub signal");
    const fileContent = fs.readFileSync(options.inputFile as string, 'utf-8');
    const jsonData = JSON.parse(fileContent);
    const payload = JSON.stringify({ input: jsonData });
    const urlObject = new URL("https://zkemail--jwt-prover-v0-1-0-flask-app.modal.run/prove/jwt");
    const reqOptions = {
      hostname: urlObject.hostname,
      path: urlObject.pathname,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload)
      }
    };
    await new Promise<void>((resolve, reject) => {
      const req = https.request(reqOptions, (res) => {
        let data = '';

        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', async () => {
          try {
            const dir = path.dirname(options.inputFile);
            const responseJson = JSON.parse(data);
            const proof = responseJson.proof;
            // console.log(proof);
            const publicSignals = responseJson.pub_signals;

            await fs.promises.writeFile(
              path.join(dir, "proof.json"),
              JSON.stringify(convertBigIntFieldsToString(proof), null, 2)
            );

            await fs.promises.writeFile(
              path.join(dir, "public.json"),
              JSON.stringify(convertBigIntFieldsToString(publicSignals), null, 2)
            );
            console.log('Files written successfully');
            resolve();
          } catch (error) {
            console.error('Error processing response:', error);
            reject(error);
          }
        });
      });

      req.on('error', (error) => {
        console.error('Error posting JSON data:', error);
        reject(error);
      });

      req.write(payload);
      req.end();
    });

  };
  // Create the request

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