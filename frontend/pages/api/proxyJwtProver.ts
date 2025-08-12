import type { NextApiRequest, NextApiResponse } from 'next';
import axios from 'axios';

// Prefer environment variables, fallback to provided sample values for local dev
const PROVER_API_URL = process.env.PROVER_API_URL || 'https://prover.zk.email/api/prove';
const PROVER_API_KEY = process.env.PROVER_API_KEY;
const PROVER_BLUEPRINT_ID = process.env.PROVER_BLUEPRINT_ID || '959b744f-a5dd-489a-9557-bd6abd42e88a';
const PROVER_ZKEY_URL =
  process.env.PROVER_ZKEY_URL || 'https://storage.googleapis.com/jwt-builder-dev/circuit.zkey.zip';
const PROVER_CIRCUIT_CPP_URL =
  process.env.PROVER_CIRCUIT_CPP_URL || 'https://storage.googleapis.com/jwt-builder-dev/circuit.wtsn.zip';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', ['POST']);
    return res.status(405).end(`Method ${req.method} Not Allowed`);
  }

  try {
    // Expecting { input: <circuitInputs> } from the client
    const { input } = req.body || {};
    if (!input) {
      return res.status(400).json({ error: 'Missing required field: input' });
    }

    if (!PROVER_API_KEY) {
      return res.status(500).json({
        error: 'Server is not configured',
        message: 'Missing PROVER_API_KEY environment variable',
      });
    }

    const payload = {
      blueprintId: PROVER_BLUEPRINT_ID,
      proofId: '',
      zkeyDownloadUrl: PROVER_ZKEY_URL,
      circuitCppDownloadUrl: PROVER_CIRCUIT_CPP_URL,
      input,
    };

    const response = await axios.post(PROVER_API_URL, payload, {
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': PROVER_API_KEY,
      },
    });

    // Normalize response to the legacy shape expected by the frontend
    // Map publicOutputs -> pub_signals
    const normalized = {
      proof: response.data.proof,
      pub_signals: response.data.publicOutputs,
    };

    res.status(200).json(normalized);
  } catch (error) {
    console.error('Error proxying request to prover service:', error);

    if (axios.isAxiosError(error)) {
      if (error.response) {
        res.status(error.response.status).json({
          error: 'Error from prover service',
          message: error.response.data,
          status: error.response.status,
        });
      } else if (error.request) {
        res.status(503).json({
          error: 'No response from prover service',
          message: 'The service might be down or unreachable',
        });
      } else {
        res.status(500).json({
          error: 'Error setting up request to prover service',
          message: error.message,
        });
      }
    } else {
      res.status(500).json({
        error: 'Unknown error occurred',
        message: 'An unexpected error occurred while processing the request',
      });
    }
  }
}
