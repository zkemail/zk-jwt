// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@zk-email/contracts/DKIMRegistry.sol";
import {JwtAuthTestBase} from "./JwtAuthBase.t.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {JwtAuth} from "../../src/JwtAuth.sol";

contract JwtAuthTest_updateJwtAuthGroth16Verifier is JwtAuthTestBase {
    constructor() {}

    function setUp() public override {
        super.setUp();
    }

    function testRevert_updateJwtAuthGroth16Verifier_OwnableUnauthorizedAccount()
        public
    {
        vm.startPrank(vm.addr(2));
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnableUpgradeable.OwnableUnauthorizedAccount.selector,
                vm.addr(2)
            )
        );
        jwtAuth.updateJwtAuthGroth16Verifier(address(groth16Verifier));
        vm.stopPrank();
    }

    function testRevert_updateJwtAuthGroth16Verifier_InvalidJwtRegistryAddress()
        public
    {
        vm.startPrank(deployer);
        vm.expectRevert("invalid groth16 verifier address");
        jwtAuth.updateJwtAuthGroth16Verifier(address(0));
        vm.stopPrank();
    }

    function test_updateJwtAuthGroth16Verifier() public {
        vm.startPrank(deployer);
        vm.expectEmit(true, true, false, false);
        emit JwtAuth.JwtAuthGroth16VerifierUpdated(address(groth16Verifier));
        jwtAuth.updateJwtAuthGroth16Verifier(address(groth16Verifier));
        vm.stopPrank();
    }
}
