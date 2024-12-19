import { NextApiRequest, NextApiResponse } from 'next';
import { generateJWTAuthenticatorInputs } from '@zk-email/jwt-tx-builder-helpers/dist/input-generators';
import relayerUtils from '@zk-email/relayer-utils';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', ['POST']);
    return res.status(405).end(`Method ${req.method} Not Allowed`);
  }

  try {
    const { jwt, pubkey, maxMessageLength } = req.body;

    if (!jwt || !pubkey || !maxMessageLength) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const accountCode = await relayerUtils.genAccountCode();
    const circuitInputs = await generateJWTAuthenticatorInputs(jwt, pubkey, accountCode, {
      maxMessageLength,
    });

    const serializedInputs = JSON.parse(
      JSON.stringify(circuitInputs, (_, value) => (typeof value === 'bigint' ? value.toString() : value)),
    );

    console.log('circuitInputs', serializedInputs);

    res.status(200).json(serializedInputs);
  } catch (error) {
    console.error('Error generating circuit inputs:', error);
    res.status(500).json({ error: 'Failed to generate inputs' });
  }
}
