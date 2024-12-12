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

contract JwtVerifierTestBase is Test {
    using Strings for *;
    using HexUtils for bytes32;

    JwtVerifier verifier;
    JwtAuthGroth16Verifier groth16Verifier;
    JwtRegistry jwtRegistry;

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
        groth16Verifier = new JwtAuthGroth16Verifier();
        ERC1967Proxy verifierProxy = new ERC1967Proxy(
            address(verifierImpl),
            abi.encodeCall(verifierImpl.initialize, (deployer))
        );
        verifier = JwtVerifier(address(verifierProxy));
        // verifier.initJwtRegistry(address(jwtRegistry));

        jwtRegistry.updateJwtVerifier(address(verifier));

        vm.stopPrank();
    }
}
