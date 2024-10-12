// script/Deploy.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Script.sol";
import "../src/utils/JwtVerifier.sol";

// 1. `source .env`
// 2. `forge script script/Deploy_jwtVerifier.s.sol:DeployScript --rpc-url $RPC_URL --verify --etherscan-api-key $ETHERSCAN_API_KEY --broadcast -vvvv`
contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        bytes32 salt = keccak256(abi.encodePacked(vm.envString("DEPLOY_SALT")));

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the contract using CREATE2
        JwtVerifier jwtVerifier = new JwtVerifier{salt: salt}();

        console.log("Contract deployed to:", address(jwtVerifier));

        vm.stopBroadcast();
    }
}