// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IJwtGroth16Verifier.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {strings} from "solidity-stringutils/src/strings.sol";
import {IVerifier} from "../interfaces/IVerifier.sol";
import {HexUtils} from "./HexUtils.sol";
import {StringToArrayUtils} from "./StringToArrayUtils.sol";
import {JwtRegistry} from "./JwtRegistry.sol";

contract JwtVerifier is IVerifier, OwnableUpgradeable, UUPSUpgradeable {
    using strings for *;
    using HexUtils for string;
    using HexUtils for bytes32;
    using StringToArrayUtils for string;

    uint256 public constant COMMAND_BYTES = 605;

    JwtRegistry internal jwtRegistry;

    event JwtRegistryUpdated(address indexed jwtRegistry);

    constructor() {}

    /// @notice Initialize the contract with the initial owner and deploy Groth16Verifier
    /// @param _initialOwner The address of the initial owner
    function initialize(
        address _initialOwner
    )
        public
        initializer
    {
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

    function verifyJwtProof(
        uint256[2] memory pA,
        uint256[2][2] memory pB,
        uint256[2] memory pC,
        uint256[] memory pubSignals,
        address groth16VerifierAddress
    ) public returns (bool) {
        // kid -> pubSignals[0]
        bytes32 kid = bytes32(uint256(pubSignals[0]));
        string memory kidString = kid.bytes32ToHexString();

        // iss -> pubSignals[1] - pubSignals[2]
        string memory issString;
        {
            bytes32 iss1 = bytes32(uint256(pubSignals[1]));
            bytes32 iss2 = bytes32(uint256(pubSignals[2]));
            issString = string(
                abi.encodePacked(
                    HexUtils.bytes32ToHexString(iss1),
                    HexUtils.bytes32ToHexString(iss2)
                )
            );
        }

        // publicKeyHash -> pubSignals[3]
        bytes32 publicKeyHash = bytes32(uint256(pubSignals[3]));

        // azp -> pubSignals[27] - pubSignals[29]
        string memory azpString;
        {
            bytes32 azp1 = bytes32(uint256(pubSignals[27]));
            bytes32 azp2 = bytes32(uint256(pubSignals[28]));
            bytes32 azp3 = bytes32(uint256(pubSignals[29]));
            azpString = string(
                abi.encodePacked(
                    HexUtils.bytes32ToHexString(azp1),
                    HexUtils.bytes32ToHexString(azp2),
                    HexUtils.bytes32ToHexString(azp3)
                )
            );
        }

        string memory domainName = string(
            abi.encodePacked(issString, "|", kidString)
        );

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

        return
            IJwtGroth16Verifier(groth16VerifierAddress).verifyProof(
                pA,
                pB,
                pC,
                pubSignals
            );
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
