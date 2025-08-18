# JWT Verifier Test Fixtures

This directory contains test fixtures for JWT verifier tests, organized into test cases.

## Structure

```
fixtures/
├── case1_signHash/         # Sign hash command test case
│   ├── raw.jwt            # Raw JWT token
│   ├── EmailProof.json    # EmailProof struct data in JSON format
│   ├── proof.json         # ZK proof data
│   └── public.json        # Public signals
├── case2_sendETH/          # Send ETH command test case  
│   ├── raw.jwt
│   ├── EmailProof.json
│   ├── proof.json
│   └── public.json
├── EmailProofFixtures.sol  # Solidity library for accessing fixtures
└── README.md
```

## Test Cases

### Case 1: Sign Hash
- **Command**: `signHash 0x8e6a49eec91c57b5722c6efe4f9c0b6d5365cc6713a6f8859d090df5a5c311cb`
- **Email**: thezdev1@gmail.com
- **Timestamp**: 1755073350
- **Purpose**: Tests hash signing functionality

### Case 2: Send ETH
- **Command**: `Send 0.12 ETH to 0xB3d489a5eF3003cB41BCd3177B087244c3F59e15`
- **Email**: thezdev2@gmail.com  
- **Timestamp**: 1755073560
- **Purpose**: Tests ETH transfer functionality

## Usage

The fixtures can be accessed in Solidity tests through the `EmailProofFixtures` library:

```solidity
import {EmailProofFixtures} from "../fixtures/EmailProofFixtures.sol";

// Get test case 1
EmailProof memory emailProof = EmailProofFixtures.getCase1SignHash();

// Get test case 2  
EmailProof memory emailProof = EmailProofFixtures.getCase2SendETH();
```

All fixtures are based on real JWT verifications that have been tested and confirmed to pass verification.