# JWT Contracts

To deploy, clone .env.sample and fill in your API and private keys, then run:

```
foundryup
source .env
forge script script/Deploy_jwtRegistry.s.sol:DeployScript --rpc-url $RPC_URL --broadcast --verify -vvvv --sender $ETH_FROM
```

Here is the sample verified deployed addresses on Sepolia:
```
JWTRegistry: 0x60Dd906E3D1d827d23Bd393aa3224fb38cac1A11
JWTVerifier implementation: 0x020FD65080C114AB55Cdeb018db197f3A8751B7F
JWTVerifier proxy: 0xD3863Ad6AD48e3dEc3736d335967b4117f64ce49
```

## Errors

```
    ├─ [1040390199] Create2Deployer::create2()
    │   ├─ [0] → new MetaMultiSigWallet@0x70EEAD58493d2cDcc62004674c95ee6C529723E1
    │   │   └─ ← [CreateCollision] EvmError: CreateCollision
    │   └─ ← [Revert] EvmError: Revert
    └─ ← [Revert] EvmError: Revert


Error:
script failed: <empty revert data>
```

This means that your salt in .env is already taken, probably on a previous deployment. Try a different one.
