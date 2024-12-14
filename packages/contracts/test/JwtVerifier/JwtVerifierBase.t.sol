// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {JwtRegistry} from "../../src/utils/JwtRegistry.sol";
import {JwtVerifier} from "../../src/utils/JwtVerifier.sol";
import {JwtAuthGroth16Verifier} from "../../src/utils/JwtAuthGroth16Verifier.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {HexUtils} from "../../src/utils/HexUtils.sol";
import {Groth16Verifier} from "../../src/utils/Groth16Verifier.sol";
import {IGroth16Verifier, Groth16Proof, G1Point, G2Point, Fp2Element} from "../../src/utils/Groth16.sol";

contract JwtVerifierTestBase is Test {
    using Strings for *;
    using HexUtils for bytes32;

    JwtVerifier verifier;
    IGroth16Verifier groth16Verifier;
    JwtRegistry jwtRegistry;

    uint[2] mockpA;
    uint[2][2] mockpB;
    uint[2] mockpC;
    uint[] mockPubSignals;
    uint[] mockExtraInput;

    // Groth16Verifier.VerifyingKey mockVk;
    Groth16Proof mockProof;

    address deployer = vm.addr(1);

    constructor() {}

    function setUp() public virtual {
        bytes32 publicKeyHash = 0x026fe6cf02399716650c42f1b9aaa9d71f2383392e217314198dfeb7208325d7;
        string
            memory issKidString = "random.website.com|5aaff47c21d06e266cce395b2145c7c6d4730ea5";
        string memory azpString = "demo-client-id";

        vm.startPrank(deployer);
        jwtRegistry = new JwtRegistry(deployer);
        jwtRegistry.setJwtPublicKey(issKidString, publicKeyHash);
        jwtRegistry.whitelistAzp(azpString);

        // Check if the publicKeyHash is registered
        require(
            jwtRegistry.isJwtPublicKeyValid(issKidString, publicKeyHash),
            "JWT Public Key Hash should be registered"
        );

        JwtVerifier verifierImpl = new JwtVerifier();
        // groth16Verifier = new JwtAuthGroth16Verifier();
        ERC1967Proxy verifierProxy = new ERC1967Proxy(
            address(verifierImpl),
            abi.encodeCall(verifierImpl.initialize, (deployer))
        );
        verifier = JwtVerifier(address(verifierProxy));
        // verifier.initJwtRegistry(address(jwtRegistry));

        // Create a mock VerifyingKey
        Groth16Verifier.VerifyingKey memory mockVk;
        mockVk.alpha1 = G1Point(1, 2);
        mockVk.beta2 = G2Point(Fp2Element(3, 4), Fp2Element(5, 6));
        mockVk.gamma2 = G2Point(Fp2Element(7, 8), Fp2Element(9, 10));
        mockVk.delta2 = G2Point(Fp2Element(11, 12), Fp2Element(13, 14));
        mockVk.ic = new G1Point[](1);
        mockVk.ic[0] = G1Point(15, 16);
        groth16Verifier = new Groth16Verifier(mockVk);

        jwtRegistry.updateJwtVerifier(address(verifier));

        // Create mock pubSignals
        mockPubSignals = new uint[](40);
        mockPubSignals[0] = 517733097421616019644180681203299748191233314469; // kid
        mockPubSignals[1] = 9533142343765075725437565513791414545047922; // iss part 1
        mockPubSignals[2] = 0; // iss part 2
        mockPubSignals[3] = 8731682816920787846178677857605537477066085281958913637355454143887928986842; // publicKeyHash
        mockPubSignals[4] = 14802577362096783432098477682082025685810039872143385070737088638565336685452; // jwtNullifier
        mockPubSignals[5] = 1694989812; // timestamp

        // maskedCommand (indices 6-25)
        for (uint i = 6; i <= 25; i++) {
            mockPubSignals[i] = i * 1000;
        }

        mockPubSignals[
            26
        ] = 0x1162ebff40918afe5305e68396f0283eb675901d0387f97d21928d423aaa0b54; // accountSalt

        // azp (indices 27-29)
        for (uint i = 27; i <= 29; i++) {
            mockPubSignals[i] = i * 2000;
        }

        // domainName (indices 32-39)
        for (uint i = 30; i <= 39; i++) {
            mockPubSignals[i] = i * 3000;
        }

        // Create a mock Groth16Proof
        mockProof.a = G1Point(1, 2);
        mockProof.b = G2Point(Fp2Element(3, 4), Fp2Element(5, 6));
        mockProof.c = G1Point(7, 8);

        vm.stopPrank();
    }
}
