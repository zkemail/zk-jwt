// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {JwtRegistry} from "../src/utils/JwtRegistry.sol";
import {JwtVerifier} from "../src/utils/JwtVerifier.sol";
import {JwtAuth} from "../src/JwtAuth.sol";
import {JwtAuthGroth16Verifier} from "../src/utils/JwtAuthGroth16Verifier.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {HexUtils} from "../src/utils/HexUtils.sol";
import {Groth16Verifier} from "../src/utils/Groth16Verifier.sol";
import {Groth16Proof, G1Point, G2Point, Fp2Element} from "../src/utils/Groth16.sol";

contract IntegrationTest is Test {
    using Strings for *;
    using HexUtils for bytes32;

    JwtVerifier verifier;
    JwtAuth jwtAuth;
    JwtRegistry jwtRegistry;

    address deployer = vm.addr(1);

    string issKidString =
        "random.website.com|5aaff47c21d06e266cce395b2145c7c6d4730ea5";
    string azpString = "demo-client-id";

    constructor() {}

    function setUp() public {
        vm.startPrank(deployer);

        // JwtAuth
        JwtAuth authImpl = new JwtAuth();
        ERC1967Proxy authProxy = new ERC1967Proxy(
            address(authImpl),
            abi.encodeCall(authImpl.initialize, (deployer))
        );
        jwtAuth = JwtAuth(address(authProxy));

        // JwtRegistry
        jwtRegistry = new JwtRegistry(deployer);

        // JwtVerifier
        JwtVerifier verifierImpl = new JwtVerifier();
        // JwtAuthGroth16Verifier groth16Verifier = new JwtAuthGroth16Verifier();
        ERC1967Proxy verifierProxy = new ERC1967Proxy(
            address(verifierImpl),
            abi.encodeCall(verifierImpl.initialize, (deployer))
        );
        verifier = JwtVerifier(address(verifierProxy));
        
        // Set up
        verifier.initJwtRegistry(address(jwtRegistry));
        jwtRegistry.updateJwtVerifier(address(verifier));
        jwtAuth.initVerifier(address(verifier));

        Groth16Verifier.VerifyingKey memory vk = vkeyFromJson(
            string.concat(
                vm.projectRoot(),
                "/test/build_integration/jwt_auth.vkey"
            )
        );

        // Groth16Verifier from codex
        Groth16Verifier groth16Verifier = new Groth16Verifier(vk);
        jwtAuth.initJwtAuthGroth16Verifier(address(groth16Verifier));

        vm.stopPrank();
    }

    function test_processCommand() public {
        console.log("test_processCommand");
        // bytes32 accountCode = 0x1162ebff40918afe5305e68396f0283eb675901d0387f97d21928d423aaa0b54;

        // // string[] memory inputGenerationInput = new string[](2);
        // // inputGenerationInput[0] = string.concat(
        // //     vm.projectRoot(),
        // //     "/test/bin/generate.sh"
        // // );
        // // inputGenerationInput[1] = uint256(accountCode).toHexString(32);
        // // vm.ffi(inputGenerationInput);

        string memory publicInputFile = vm.readFile(
            string.concat(
                vm.projectRoot(),
                "/test/build_integration/jwt_auth_public.json"
            )
        );
        string[] memory pubSignalsStrings = abi.decode(
            vm.parseJson(publicInputFile),
            (string[])
        );

        uint256[] memory pubSignals = new uint256[](pubSignalsStrings.length);
        for (uint i = 0; i < pubSignalsStrings.length; i++) {
            pubSignals[i] = stringToUint(pubSignalsStrings[i]);
        }

        vm.startPrank(deployer);
        // publicKeyHash -> pubSignals[3]
        bytes32 publicKeyHash = bytes32(uint256(pubSignals[3]));
        jwtRegistry.setJwtPublicKey(issKidString, publicKeyHash);
        jwtRegistry.whitelistAzp(azpString);
        vm.stopPrank();

        // Check if the publicKeyHash is registered
        // console.log(issKidString);
        // console.logBytes32(publicKeyHash);
        require(
            jwtRegistry.isJwtPublicKeyValid(issKidString, publicKeyHash),
            "JWT Public Key Hash should be registered"
        );

        bytes memory proof = proofToBytes(
            string.concat(
                vm.projectRoot(),
                "/test/build_integration/jwt_auth_proof.json"
            )
        );
        Groth16Proof memory groth16Proof;
        {
            (
                uint256[2] memory pA,
                uint256[2][2] memory pB,
                uint256[2] memory pC
            ) = abi.decode(proof, (uint256[2], uint256[2][2], uint256[2]));

            // Create a Groth16Proof from pA, pB, and pC
            groth16Proof = Groth16Proof(
                G1Point(pA[0], pA[1]),
                G2Point(
                    Fp2Element(pB[0][0], pB[0][1]),
                    Fp2Element(pB[1][0], pB[1][1])
                ),
                G1Point(pC[0], pC[1])
            );
        }

        jwtAuth.processCommand(groth16Proof, pubSignals, new uint[](0));
    }

    function stringToUint(string memory s) internal pure returns (uint256) {
        bytes memory b = bytes(s);
        uint256 result = 0;
        for (uint i = 0; i < b.length; i++) {
            if (b[i] >= 0x30 && b[i] <= 0x39) {
                result = result * 10 + (uint256(uint8(b[i])) - 48);
            }
        }
        return result;
    }

    function proofToBytes(
        string memory proofPath
    ) internal view returns (bytes memory) {
        string memory proofFile = vm.readFile(proofPath);
        string[] memory pi_a = abi.decode(
            vm.parseJson(proofFile, ".pi_a"),
            (string[])
        );
        uint256[2] memory pA = [vm.parseUint(pi_a[0]), vm.parseUint(pi_a[1])];
        string[][] memory pi_b = abi.decode(
            vm.parseJson(proofFile, ".pi_b"),
            (string[][])
        );
        uint256[2][2] memory pB = [
            [vm.parseUint(pi_b[0][1]), vm.parseUint(pi_b[0][0])],
            [vm.parseUint(pi_b[1][1]), vm.parseUint(pi_b[1][0])]
        ];
        string[] memory pi_c = abi.decode(
            vm.parseJson(proofFile, ".pi_c"),
            (string[])
        );
        uint256[2] memory pC = [vm.parseUint(pi_c[0]), vm.parseUint(pi_c[1])];
        bytes memory proof = abi.encode(pA, pB, pC);
        return proof;
    }

    function vkeyFromJson(string memory vkeyPath) internal view returns (Groth16Verifier.VerifyingKey memory vk) {
        string memory vkeyFile = vm.readFile(vkeyPath);

        // Parse vk_alpha_1
        string[] memory vk_alpha_1 = abi.decode(vm.parseJson(vkeyFile, ".vk_alpha_1"), (string[]));
        vk.alpha1 = G1Point(stringToUint(vk_alpha_1[0]), stringToUint(vk_alpha_1[1]));
        // console.log("vk.alpha1");
        // console.log(vk.alpha1.x);
        // console.log(vk.alpha1.y);

        // Parse vk_beta_2
        string[][] memory vk_beta_2 = abi.decode(vm.parseJson(vkeyFile, ".vk_beta_2"), (string[][]));
        vk.beta2 = G2Point(
            Fp2Element(stringToUint(vk_beta_2[0][0]), stringToUint(vk_beta_2[0][1])),
            Fp2Element(stringToUint(vk_beta_2[1][0]), stringToUint(vk_beta_2[1][1]))
        );
        // console.log("vk.beta2");
        // console.log(vk.beta2.x.real);
        // console.log(vk.beta2.x.imag);
        // console.log(vk.beta2.y.real);
        // console.log(vk.beta2.y.imag);
                
        // Parse vk_gamma_2
        string[][] memory vk_gamma_2 = abi.decode(vm.parseJson(vkeyFile, ".vk_gamma_2"), (string[][]));
        vk.gamma2 = G2Point(
            Fp2Element(stringToUint(vk_gamma_2[0][0]), stringToUint(vk_gamma_2[0][1])),
            Fp2Element(stringToUint(vk_gamma_2[1][0]), stringToUint(vk_gamma_2[1][1]))
        );
        // console.log("vk.gamma2");
        // console.log(vk.gamma2.x.real);
        // console.log(vk.gamma2.x.imag);
        // console.log(vk.gamma2.y.real);
        // console.log(vk.gamma2.y.imag);

        // Parse vk_delta_2
        string[][] memory vk_delta_2 = abi.decode(vm.parseJson(vkeyFile, ".vk_delta_2"), (string[][]));
        vk.delta2 = G2Point(
            Fp2Element(stringToUint(vk_delta_2[0][0]), stringToUint(vk_delta_2[0][1])),
            Fp2Element(stringToUint(vk_delta_2[1][0]), stringToUint(vk_delta_2[1][1]))
        );
        // console.log("vk.delta2");
        // console.log(vk.delta2.x.real);
        // console.log(vk.delta2.x.imag);
        // console.log(vk.delta2.y.real);
        // console.log(vk.delta2.y.imag);

        // Parse IC
        string[][] memory IC = abi.decode(vm.parseJson(vkeyFile, ".IC"), (string[][]));
        vk.ic = new G1Point[](IC.length);
        for (uint i = 0; i < IC.length; i++) {
            vk.ic[i] = G1Point(stringToUint(IC[i][0]), stringToUint(IC[i][1]));
        }
        // console.log("vk.ic");
        // for(uint i = 0; i < IC.length; i++) {
        //     console.log(vk.ic[i].x);
        //     console.log(vk.ic[i].y);
        // }
        return vk;
    }    
}
