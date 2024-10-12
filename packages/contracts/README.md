# JWT Contracts

To deploy, clone .env.sample and fill in your API and private keys, then run:

```
foundryup
source .env
forge script script/Deploy_jwtRegistry.s.sol:DeployScript --rpc-url $RPC_URL --broadcast --verify -vvvv --sender $ETH_FROM
```

Here are some sample verified addresses on Base Sepolia:
```
JWTRegistry: 0x9630BFd4D20eFB2645BCE25603C7e88D1c544B05
```
