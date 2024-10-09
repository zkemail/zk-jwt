// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {EmailProof, JwtVerifier} from "../../src/utils/JwtVerifier.sol";
import {JwtGroth16Verifier} from "../../src/utils/JwtGroth16Verifier.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract JwtVerifierTest_verifyEmailProof is Test {
    JwtVerifier verifier;

    constructor() {}

    function setUp() public {
        JwtVerifier verifierImpl = new JwtVerifier();
        JwtGroth16Verifier groth16Verifier = new JwtGroth16Verifier();
        ERC1967Proxy verifierProxy = new ERC1967Proxy(
            address(verifierImpl),
            abi.encodeCall(
                verifierImpl.initialize,
                (msg.sender, address(groth16Verifier))
            )
        );
        verifier = JwtVerifier(address(verifierProxy));
    }

    function test_verifyEmailProof() public {
        // account code = 16351800486276213158813915254152097017375347006603152442842997572625254103242
        console.log("test_verifyEmailProof");
        EmailProof memory emailProof;
        emailProof.domainName = "0x5aaff47c21d06e266cce395b2145c7c6d4730ea5|random.website.com|demo-client-id";
        emailProof.publicKeyHash = bytes32(0x17b17b71ba34d6771b91f2689fddf7266d561d4dcc5d43174d0e100468d89685);
        emailProof.timestamp = 1694989812;
        emailProof.maskedCommand = "Send 0.1 ETH to alice@gmail.com";
        emailProof.emailNullifier = bytes32(0x24dc5e63ebcbbe243ef41484ec2d97a6ea130387702a9cad6aea2193457d5aec);
        emailProof.accountSalt = bytes32(0x2426ca85629574124b746006d8d50f7e7c0e3a0d91a9cdf6c477e314ed14b8ca);
        emailProof.isCodeExist = true;
        emailProof.proof = proofToBytes(
            string.concat(
                vm.projectRoot(),
                "/test/jwt_proofs/proof.json"
            )
        );
        verifier.verifyEmailProof(emailProof);
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

}