// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IJwtGroth16Verifier.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {strings} from "solidity-stringutils/src/strings.sol";
import {IVerifier} from "../interfaces/IVerifier.sol";
import {HexUtils} from "./HexUtils.sol";
import {JwtAuthGroth16Verifier} from "./JwtAuthGroth16Verifier.sol";
import {StringToArrayUtils} from "./StringToArrayUtils.sol";
import {JwtRegistry} from "./JwtRegistry.sol";
import {Groth16Proof, IGroth16Verifier} from "./Groth16.sol";

import "forge-std/console.sol";

contract JwtVerifier is IVerifier, OwnableUpgradeable, UUPSUpgradeable {
    using strings for *;
    using HexUtils for string;
    using HexUtils for bytes32;
    using StringToArrayUtils for string;

    uint256 public constant ISS_BYTES = 32;
    uint256 public constant AZP_BYTES = 72;
    uint256 public constant COMMAND_BYTES = 605;

    JwtRegistry internal jwtRegistry;

    event JwtRegistryUpdated(address indexed jwtRegistry);

    constructor() {}

    /// @notice Initialize the contract with the initial owner and deploy Groth16Verifier
    /// @param _initialOwner The address of the initial owner
    function initialize(address _initialOwner) public initializer {
        __Ownable_init(_initialOwner);
    }

    /// @notice Initializes the address of the JWT registry contract.
    /// @param _jwtRegistryAddr The address of the JWT registry contract.
    function initJwtRegistry(address _jwtRegistryAddr) public onlyOwner {
        require(_jwtRegistryAddr != address(0), "invalid jwt registry address");
        require(
            address(jwtRegistry) == address(0),
            "jwt registry already initialized"
        );
        jwtRegistry = JwtRegistry(_jwtRegistryAddr);
        emit JwtRegistryUpdated(_jwtRegistryAddr);
    }

    /// @notice Updates the address of the JWT registry contract.
    /// @param _jwtRegistryAddr The new address of the JWT registry contract.
    function updateJwtRegistry(address _jwtRegistryAddr) public onlyOwner {
        require(_jwtRegistryAddr != address(0), "invalid jwt registry address");
        jwtRegistry = JwtRegistry(_jwtRegistryAddr);
        emit JwtRegistryUpdated(_jwtRegistryAddr);
    }

    function logPubSignals(uint256[] memory pubSignals) private view {
        require(pubSignals.length == 40, "pubSignals length must be 40");

        for (uint256 i = 0; i < pubSignals.length; i++) {
            console.log("pubSignals[", i, "] = ", pubSignals[i]);
        }
    }

    function verifyJwtProof(
        Groth16Proof calldata proof,
        uint256[] memory pubSignals,
        address groth16VerifierAddress
    ) public returns (bool) {
        logPubSignals(pubSignals);

        // kid -> pubSignals[0]
        bytes32 kid = bytes32(uint256(pubSignals[0]));
        string memory kidString = kid.bytes32ToHexString();
        console.log("kidString");
        console.log(kidString);

        // iss -> pubSignals[1] - pubSignals[2]
        string memory issString;
        {
            uint256[] memory pubSignalsArray = new uint256[](2);
            pubSignalsArray[0] = pubSignals[1];
            pubSignalsArray[1] = pubSignals[2];
            bytes memory iss = _unpackFields2Bytes(pubSignalsArray, ISS_BYTES);
            issString = string(abi.encodePacked(iss));
        }
        console.log("issString");
        console.log(issString);

        // publicKeyHash -> pubSignals[3]
        bytes32 publicKeyHash = bytes32(uint256(pubSignals[3]));
        console.log("publicKeyHash");
        console.logBytes32(publicKeyHash);

        // azp -> pubSignals[27] - pubSignals[29]
        string memory azpString;
        {
            uint256[] memory pubSignalsArray = new uint256[](2);
            pubSignalsArray[0] = pubSignals[27];
            pubSignalsArray[1] = pubSignals[28];
            pubSignalsArray[1] = pubSignals[29];
            bytes memory azp = _unpackFields2Bytes(pubSignalsArray, AZP_BYTES);
            azpString = string(abi.encodePacked(azp));
        }
        console.log("azpString");
        console.log(azpString);

        string memory domainName = string(
            abi.encodePacked(issString, "|", kidString)
        );
        console.log("domainName");
        console.log(domainName);

        // Check JwtRegistry,
        // if it returns false, then call updateJwtRegistry,
        // and then try isJwtPublicKeyValid again.
        if (!jwtRegistry.isJwtPublicKeyValid(domainName, publicKeyHash)) {
            jwtRegistry.updateJwtRegistry();
            require(
                jwtRegistry.isJwtPublicKeyValid(domainName, publicKeyHash),
                "Invalid public key hash"
            );
        }
        // Check if azp is in whitelist
        require(
            jwtRegistry.isAzpWhitelisted(azpString),
            "azp is not whitelisted"
        );
        console.log("before verifyProof");

        // uint[40] memory fixedPubSignals;
        // for (uint i = 0; i < 40; i++) {
        //     fixedPubSignals[i] = pubSignals[i];
        // }

        bool result = IGroth16Verifier(groth16VerifierAddress).verify(
            proof,
            pubSignals
        );
        console.log("after verifyProof");
        return result;
    }

    function _unpackFields2Bytes(
        uint256[] memory _fields,
        uint256 _originalSize
    ) private pure returns (bytes memory) {
        bytes memory tempResult = new bytes(_originalSize);
        uint256 idx = 0;
        for (uint256 i = 0; i < _fields.length; i++) {
            for (uint256 j = 0; j < 31; j++) {
                if (idx >= _originalSize) {
                    break;
                }
                uint8 byteVal = uint8((_fields[i] >> (8 * j)) & 0xFF);
                tempResult[idx] = bytes1(byteVal);
                idx++;
            }
        }

        // Count non-null bytes
        uint256 nonNullLength = 0;
        for (uint256 i = 0; i < tempResult.length; i++) {
            if (tempResult[i] != 0) {
                nonNullLength++;
            }
        }

        // Create a new bytes array without null bytes
        bytes memory result = new bytes(nonNullLength);
        uint256 index = 0;
        for (uint256 i = 0; i < tempResult.length; i++) {
            if (tempResult[i] != 0) {
                result[index] = tempResult[i];
                index++;
            }
        }

        return result;
    }

    function _packBytes2Fields(
        bytes memory _bytes,
        uint256 _paddedSize
    ) public pure returns (uint256[] memory) {
        uint256 remain = _paddedSize % 31;
        uint256 numFields = (_paddedSize - remain) / 31;
        if (remain > 0) {
            numFields += 1;
        }
        uint256[] memory fields = new uint[](numFields);
        uint256 idx = 0;
        uint256 byteVal = 0;
        for (uint256 i = 0; i < numFields; i++) {
            for (uint256 j = 0; j < 31; j++) {
                idx = i * 31 + j;
                if (idx >= _paddedSize) {
                    break;
                }
                if (idx >= _bytes.length) {
                    byteVal = 0;
                } else {
                    byteVal = uint256(uint8(_bytes[idx]));
                }
                if (j == 0) {
                    fields[i] = byteVal;
                } else {
                    fields[i] += (byteVal << (8 * j));
                }
            }
        }
        return fields;
    }

    /// @notice Upgrade the implementation of the proxy.
    /// @param newImplementation Address of the new implementation.
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    function getCommandBytes() external pure returns (uint256) {
        return COMMAND_BYTES;
    }
}
