import { NextApiRequest, NextApiResponse } from "next";
import { generateJWTVerifierInputs } from "../../../packages/helpers/src/input-generators";
import { genAccountCode } from "@zk-email/relayer-utils";

export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse
) {
    if (req.method === "POST") {
        try {
            const { jwt, publicKey, maxMessageLength } = req.body;
            const accountCode = await genAccountCode();
            const inputs = await generateJWTVerifierInputs(
                jwt,
                publicKey,
                BigInt(accountCode),
                {
                    maxMessageLength: maxMessageLength,
                }
            );
            res.status(200).json(inputs);
        } catch (error) {
            res.status(500).json({ error: "Failed to generate inputs" });
        }
    } else {
        res.setHeader("Allow", ["POST"]);
        res.status(405).end(`Method ${req.method} Not Allowed`);
    }
}
