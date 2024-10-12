import { NextApiRequest, NextApiResponse } from "next";
import { generateJWTVerifierInputs } from "@zk-jwt/helpers/dist/input-generators";
import { genAccountCode } from "@zk-email/relayer-utils";

export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse
) {
    if (req.method === "POST") {
        try {
            console.log("req.body", req.body);
            const { jwt, pubkey, maxMessageLength } = req.body;
            if (!jwt || !pubkey || !maxMessageLength) {
                res.status(400).json({ error: "Missing required fields" });
                return;
            }
            const accountCode = await genAccountCode();
            console.log("accountCode", accountCode);
            const circuitInputs = await generateJWTVerifierInputs(
                jwt,
                pubkey,
                accountCode,
                {
                    maxMessageLength: maxMessageLength,
                }
            );
            console.log("circuitInputs", circuitInputs);
            res.status(200).json(circuitInputs);
        } catch (error) {
            res.status(500).json({ error: "Failed to generate inputs" });
        }
    } else {
        res.setHeader("Allow", ["POST"]);
        res.status(405).end(`Method ${req.method} Not Allowed`);
    }
}
