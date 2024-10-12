// script/Deploy.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Script.sol";
import "../src/utils/JwtRegistry.sol";

// 1. `source .env`
// 2. `forge script script/Deploy_jwtRegistry.s.sol:DeployScript --rpc-url $RPC_URL --verify --etherscan-api-key $ETHERSCAN_API_KEY --broadcast -vvvv`
contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        bytes32 salt = keccak256(abi.encodePacked(vm.envString("DEPLOY_SALT")));

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the contract using CREATE2
        JwtRegistry jwtRegistry = new JwtRegistry{salt: salt}(deployer);

        console.log("Contract deployed to:", address(jwtRegistry));

        vm.stopBroadcast();
    }
}