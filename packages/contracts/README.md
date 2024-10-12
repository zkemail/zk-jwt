# JWT Contracts

To deploy, clone .env.sample and fill in your API and private keys, then run:

```
foundryup
source .env
forge script script/Deploy_jwtRegistry.s.sol:DeployScript --rpc-url $RPC_URL --broadcast --verify -vvvv --sender $ETH_FROM
```

Here is the sample verified deployed addresses on Sepolia:
```
JWTRegistry: 0x983A7B6a8b5657319078D858a303830C99761108
DKIMRegistry: 0xf3B70Dc348C7820b3026564500A7eBAc6cC4cC33
JWTVerifier implementation: 0xF462839975B5e1844dD32cb301aFE65D0Dbe66Dd
JWTVerifier proxy: 0x63E990e29317Bf54a6c4F5Fb26e33342D3DE6Fd3
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
