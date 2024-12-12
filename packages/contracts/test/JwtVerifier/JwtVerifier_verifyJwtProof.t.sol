// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@zk-email/contracts/DKIMRegistry.sol";
import {JwtVerifier} from "../../src/utils/JwtVerifier.sol";
import {JwtRegistry} from "../../src/utils/JwtRegistry.sol";
import {JwtAuthGroth16Verifier} from "../../src/utils/JwtAuthGroth16Verifier.sol";
import {IJwtGroth16Verifier} from "../../src/interfaces/IJwtGroth16Verifier.sol";
import {JwtVerifierTestBase} from "./JwtVerifierBase.t.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract JwtVerifierTest_verifyJwtProof is JwtVerifierTestBase {
    uint[2] mockpA;
    uint[2][2] mockpB;
    uint[2] mockpC;
    uint[] mockPubSignals;
    uint[] mockExtraInput;

    constructor() {}

    function setUp() public override {
        super.setUp();

        mockPubSignals = new uint[](40);
        mockPubSignals[0] = 1111; // kid
        mockPubSignals[1] = 1111; // iss part 1
        mockPubSignals[2] = 1111; // iss part 2
        mockPubSignals[3] = 1111; // publicKeyHash
        mockPubSignals[4] = 1111; // jwtNullifier
        mockPubSignals[5] = 1694989812; // timestamp

        // maskedCommand (indices 6-25)
        for (uint i = 6; i <= 25; i++) {
            mockPubSignals[i] = i * 1000;
        }

        mockPubSignals[
            26
        ] = 0x1162ebff40918afe5305e68396f0283eb675901d0387f97d21928d423aaa0b54; // accountSalt

        // azp (indices 27-31)
        for (uint i = 27; i <= 29; i++) {
            mockPubSignals[i] = i * 2000;
        }

        // domainName (indices 32-39)
        for (uint i = 30; i <= 39; i++) {
            mockPubSignals[i] = i * 3000;
        }
    }

    function testRevert_verifyJwtProof_NotJwtVerifier() public {
        vm.startPrank(deployer);
        verifier.initJwtRegistry(address(jwtRegistry));
        jwtRegistry.updateJwtVerifier(deployer);
        vm.expectRevert("only jwtVerifier");
        verifier.verifyJwtProof(
            mockpA,
            mockpB,
            mockpC,
            mockPubSignals,
            address(groth16Verifier)
        );
        vm.stopPrank();
    }

    function testRevert_verifyJwtProof_InvalidPublicKeyHash() public {
        vm.startPrank(deployer);
        verifier.initJwtRegistry(address(jwtRegistry));
        vm.expectRevert("Invalid public key hash");
        verifier.verifyJwtProof(
            mockpA,
            mockpB,
            mockpC,
            mockPubSignals,
            address(groth16Verifier)
        );
        vm.stopPrank();
    }

    function testRevert_verifyJwtProof_AzpIsNotWhitelisted() public {
        vm.startPrank(deployer);
        verifier.initJwtRegistry(address(jwtRegistry));
        vm.mockCall(
            address(jwtRegistry),
            abi.encodeWithSelector(
                JwtRegistry.isJwtPublicKeyHashValid.selector
            ),
            abi.encode(true)
        );
        vm.expectRevert("azp is not whitelisted");
        verifier.verifyJwtProof(
            mockpA,
            mockpB,
            mockpC,
            mockPubSignals,
            address(groth16Verifier)
        );
        vm.stopPrank();
    }

    function test_verifyJwtProof_InvalidJwtProof() public {
        vm.startPrank(deployer);
        verifier.initJwtRegistry(address(jwtRegistry));
        vm.mockCall(
            address(jwtRegistry),
            abi.encodeWithSelector(
                JwtRegistry.isJwtPublicKeyHashValid.selector
            ),
            abi.encode(true)
        );
        vm.mockCall(
            address(jwtRegistry),
            abi.encodeWithSelector(JwtRegistry.isAzpWhitelisted.selector),
            abi.encode(true)
        );
        vm.mockCall(
            address(groth16Verifier),
            abi.encodeWithSelector(IJwtGroth16Verifier.verifyProof.selector),
            abi.encode(false)
        );
        bool result = verifier.verifyJwtProof(
            mockpA,
            mockpB,
            mockpC,
            mockPubSignals,
            address(groth16Verifier)
        );
        assertFalse(result);
        vm.stopPrank();
    }

    function test_verifyJwtProof() public {
        vm.startPrank(deployer);
        verifier.initJwtRegistry(address(jwtRegistry));
        vm.mockCall(
            address(jwtRegistry),
            abi.encodeWithSelector(
                JwtRegistry.isJwtPublicKeyHashValid.selector
            ),
            abi.encode(true)
        );
        vm.mockCall(
            address(jwtRegistry),
            abi.encodeWithSelector(JwtRegistry.isAzpWhitelisted.selector),
            abi.encode(true)
        );
        vm.mockCall(
            address(groth16Verifier),
            abi.encodeWithSelector(IJwtGroth16Verifier.verifyProof.selector),
            abi.encode(true)
        );
        bool result = verifier.verifyJwtProof(
            mockpA,
            mockpB,
            mockpC,
            mockPubSignals,
            address(groth16Verifier)
        );
        assertTrue(result);
        vm.stopPrank();
    }
}
