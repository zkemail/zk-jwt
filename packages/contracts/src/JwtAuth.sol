// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {JwtRegistry} from "./utils/JwtRegistry.sol";
import {IVerifier} from "./interfaces/IVerifier.sol";

/// @title JWT Auth
/// @notice TODO
/// @dev TODO
contract JwtAuth is OwnableUpgradeable, UUPSUpgradeable {
    // /// An instance of the JWT registry contract.
    // JwtRegistry internal jwtRegistry;
    /// An instance of the Verifier contract.
    IVerifier internal verifier;
    /// A mapping of the hash of the authorized message associated with its `jwtNullifier`.
    mapping(bytes32 => bool) public usedNullifiers;

    address public jwtAuthGroth16VerifierAddress;

    // event JwtRegistryUpdated(address indexed jwtRegistry);
    event VerifierUpdated(address indexed verifier);
    event JwtAuthGroth16VerifierUpdated(address indexed verifier);
    // event JwtAuthed(
    //     bytes32 indexed jwtNullifier,
    //     bool isCodeExist,
    //     string indexed domainName,
    //     string indexed azp
    // );

    constructor() {}

    /// @notice Initialize the contract with an initial owner and Groth16 verifier address
    /// @param _initialOwner The address of the initial owner
    function initialize(address _initialOwner) public initializer {
        __Ownable_init(_initialOwner);
    }

    // /// @notice Initializes the address of the JWT registry contract.
    // /// @param _jwtRegistryAddr The address of the JWT registry contract.
    // function initJwtRegistry(address _jwtRegistryAddr) public onlyOwner {
    //     require(_jwtRegistryAddr != address(0), "invalid jwt registry address");
    //     require(
    //         address(jwtRegistry) == address(0),
    //         "jwt registry already initialized"
    //     );
    //     jwtRegistry = JwtRegistry(_jwtRegistryAddr);
    //     emit JwtRegistryUpdated(_jwtRegistryAddr);
    // }

    /// @notice Initializes the address of the verifier contract.
    /// @param _verifierAddr The address of the verifier contract.
    function initVerifier(address _verifierAddr) public onlyOwner {
        require(_verifierAddr != address(0), "invalid verifier address");
        require(
            address(verifier) == address(0),
            "verifier already initialized"
        );
        verifier = IVerifier(_verifierAddr);
        emit VerifierUpdated(_verifierAddr);
    }

    /// @notice Updates the address of the verifier contract.
    /// @param _verifierAddr The new address of the verifier contract.
    function updateVerifier(address _verifierAddr) public onlyOwner {
        require(_verifierAddr != address(0), "invalid verifier address");
        verifier = IVerifier(_verifierAddr);
        emit VerifierUpdated(_verifierAddr);
    }

    /// @notice Initializes the address of the verifier contract.
    /// @param _groth16verifierAddr The address of the groth16 verifier contract.
    function initJwtAuthGroth16Verifier(
        address _groth16verifierAddr
    ) public onlyOwner {
        require(
            _groth16verifierAddr != address(0),
            "invalid groth16 verifier address"
        );
        require(
            address(jwtAuthGroth16VerifierAddress) == address(0),
            "verifier already initialized"
        );
        jwtAuthGroth16VerifierAddress = _groth16verifierAddr;
        emit JwtAuthGroth16VerifierUpdated(_groth16verifierAddr);
    }

    /// @notice Updates the address of the verifier contract.
    /// @param _groth16verifierAddr The new address of the groth16 verifier contract.
    function updateJwtAuthGroth16Verifier(
        address _groth16verifierAddr
    ) public onlyOwner {
        require(
            _groth16verifierAddr != address(0),
            "invalid groth16 verifier address"
        );
        jwtAuthGroth16VerifierAddress = _groth16verifierAddr;
        emit JwtAuthGroth16VerifierUpdated(_groth16verifierAddr);
    }

    function processCommand(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[] calldata _pubSignals,
        uint[] calldata _extraInput
    ) public onlyOwner {
        require(
            verifier.verifyJwtProof(
                _pA,
                _pB,
                _pC,
                _pubSignals,
                jwtAuthGroth16VerifierAddress
            ) == true,
            "invalid jwt proof"
        );

        // process extra input
    }

    /// @notice Upgrade the implementation of the proxy.
    /// @param newImplementation Address of the new implementation.
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
