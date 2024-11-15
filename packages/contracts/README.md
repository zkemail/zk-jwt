# JWT Contracts

This directory contains verifier contracts for handling JSON Web Tokens(JWTs) proofs. 

## Contracts Overview

### JWTRegistry

- **Purpose**: The `JWTRegistry` contract is used to store and manage JWTs. It keeps track of all issued tokens and their statuses.
- **Usage**: In another project, you can use this contract to verify if a JWT is valid and to check its status (active, revoked, etc.).

### JWTVerifier

- **Purpose**: The `JWTVerifier` contract is responsible for verifying the authenticity of JWTs. It checks the proof and ensures the token is valid.
- **Usage**: Use this contract in your project to verify JWTs proof before granting access to protected resources.

## How to Use in Another Project

1. **Installation**: First, install the package using npm. Run the following command in your project directory:

   ```
   npm install @zk-jwt/zk-jwt-contracts
   ```

2. **Integration**: 
   - **Solidity**: Import the contracts in your Solidity files using the following syntax:

     ```solidity
     import {JwtVerifier} from "@zk-jwt/zk-jwt-contracts/utils/JwtVerifier.sol";
     import {JwtGroth16Verifier} from "@zk-jwt/zk-jwt-contracts/utils/JwtGroth16Verifier.sol";
     import {JwtRegistry} from "@zk-jwt/zk-jwt-contracts/utils/JwtRegistry.sol";
     ```

## Example Deployment

To deploy, run the following commands:

```
foundryup
source .env
forge script script/Deploy_jwtRegistry.s.sol:DeployScript --rpc-url $RPC_URL --broadcast --verify -vvvv --sender $ETH_FROM
```

## Sample Deployed Addresses

Here are some example addresses where the contracts have been deployed on Base Sepolia test network:

- **JWTRegistry**: `0x60Dd906E3D1d827d23Bd393aa3224fb38cac1A11`
- **JWTVerifier Implementation**: `0x020FD65080C114AB55Cdeb018db197f3A8751B7F`
- **JWTVerifier Proxy**: `0xD3863Ad6AD48e3dEc3736d335967b4117f64ce49`

## Troubleshooting

If you encounter a `CreateCollision` error, it means the salt in your `.env` file is already used. Try using a different salt value.

```
Error:
script failed: <empty revert data>
```

This error indicates a problem with the deployment script. Check your environment variables and try again.
