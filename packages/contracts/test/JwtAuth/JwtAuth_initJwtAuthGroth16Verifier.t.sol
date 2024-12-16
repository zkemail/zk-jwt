// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@zk-email/contracts/DKIMRegistry.sol";
import {JwtAuthTestBase} from "./JwtAuthBase.t.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {JwtAuth} from "../../src/JwtAuth.sol";

contract JwtAuthTest_initJwtAuthGroth16Verifier is JwtAuthTestBase {
    constructor() {}

    function setUp() public override {
        super.setUp();
    }

    function testRevert_initJwtAuthGroth16Verifier_OwnableUnauthorizedAccount()
        public
    {
        vm.startPrank(vm.addr(2));
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnableUpgradeable.OwnableUnauthorizedAccount.selector,
                vm.addr(2)
            )
        );
        jwtAuth.initJwtAuthGroth16Verifier(address(groth16Verifier));
        vm.stopPrank();
    }

    function testRevert_initJwtAuthGroth16Verifier_InvalidJwtRegistryAddress()
        public
    {
        vm.startPrank(deployer);
        vm.expectRevert("invalid groth16 verifier address");
        jwtAuth.initJwtAuthGroth16Verifier(address(0));
        vm.stopPrank();
    }

    function testRevert_initJwtAuthGroth16Verifier_AlreadyInitialized() public {
        vm.startPrank(deployer);
        vm.expectEmit(true, true, false, false);
        emit JwtAuth.JwtAuthGroth16VerifierUpdated(address(groth16Verifier));
        jwtAuth.initJwtAuthGroth16Verifier(address(groth16Verifier));
        vm.expectRevert("groth16 verifier already initialized");
        jwtAuth.initJwtAuthGroth16Verifier(address(groth16Verifier));
        vm.stopPrank();
    }

    function test_initJwtAuthGroth16Verifier() public {
        vm.startPrank(deployer);
        vm.expectEmit(true, true, false, false);
        emit JwtAuth.JwtAuthGroth16VerifierUpdated(address(groth16Verifier));
        jwtAuth.initJwtAuthGroth16Verifier(address(groth16Verifier));
        vm.stopPrank();
    }
}
