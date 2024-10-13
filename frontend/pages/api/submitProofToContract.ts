import { NextApiRequest, NextApiResponse } from "next";
import { createPublicClient, http, createWalletClient } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { sepolia } from "viem/chains";
import { config } from "dotenv";
import { encodeAbiParameters, parseAbiParameters } from "viem";

import { abi as contractABI } from "../../public/JwtVerifier.json";
const contractAddress = "0x63E990e29317Bf54a6c4F5Fb26e33342D3DE6Fd3";

config();
const privateKey = process.env.PRIVATE_KEY;

if (!privateKey) {
    throw new Error("PRIVATE_KEY environment variable is not set");
}

const publicClient = createPublicClient({
    chain: sepolia,
    transport: http(),
});

const walletClient = createWalletClient({
    chain: sepolia,
    transport: http(),
});

const account = privateKeyToAccount(`0x${privateKey}`);

export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse
) {
    if (req.method !== "POST") {
        res.setHeader("Allow", ["POST"]);
        return res.status(405).end(`Method ${req.method} Not Allowed`);
    }

    try {
        console.log("Request body:", req.body);
        const { proof, pub_signals, header, payload } = req.body;
        console.log("Proof:", proof);
        console.log("Pub signals:", pub_signals);

        if (!proof || !pub_signals) {
            return res.status(400).json({
                error: "Missing proof or pub_signals in request body",
            });
        }

        const jwtProof = {
            domainName: `${header.kid}|${payload.iss}|${payload.azp}`,
            publicKeyHash: `0x${BigInt(pub_signals[3]).toString(16).padStart(64, "0")}`,
            timestamp: BigInt(pub_signals[5]).toString(),
            maskedCommand: payload.nonce,
            emailNullifier: `0x${BigInt(pub_signals[4]).toString(16).padStart(64, "0")}`,
            accountSalt: `0x${BigInt(pub_signals[26]).toString(16).padStart(64, "0")}`,
            isCodeExist: Boolean(pub_signals[30]),
            proof: encodeAbiParameters(
                parseAbiParameters("uint256[2], uint256[2][2], uint256[2]"),
                [
                    proof.pi_a.slice(0, 2).map(BigInt),
                    [
                        proof.pi_b[0].slice(0, 2).map(BigInt),
                        proof.pi_b[1].slice(0, 2).map(BigInt),
                    ],
                    proof.pi_c.slice(0, 2).map(BigInt),
                ]
            ),
        };
        console.log("JWT proof:", jwtProof);

        const { request } = await publicClient.simulateContract({
            account,
            address: contractAddress,
            abi: contractABI,
            functionName: "verifyEmailProof",
            args: [jwtProof],
        });
        console.log("Contract request:", request);
        const hash = await walletClient.writeContract(request);
        console.log("Transaction hash:", hash);
        const receipt = await publicClient.waitForTransactionReceipt({ hash });
        console.log("Transaction receipt:", receipt);

        res.status(200).json({
            message: "Proof submitted successfully",
            transactionHash: hash,
            blockNumber: receipt.blockNumber.toString(),
        });
    } catch (error) {
        console.error("Error submitting proof to contract:", error);
        res.status(500).json({
            error: "Failed to submit proof to contract",
            message:
                error instanceof Error
                    ? error.message
                    : "Unknown error occurred",
        });
    }
}
