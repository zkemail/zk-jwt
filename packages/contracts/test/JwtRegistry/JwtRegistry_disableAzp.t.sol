// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@zk-email/contracts/DKIMRegistry.sol";
import {JwtRegistryTestBase} from "./JwtRegistryBase.t.sol";

contract JwtRegistryTest_disableAzp is JwtRegistryTestBase {
    constructor() {}

    function setUp() public override {
        super.setUp();
    }

    function testRevert_disableAzp_invalidDomainNameFormat() public {
        string memory invalidDomainName = "12345|https://example.com";
        vm.expectRevert(bytes("Invalid kid|iss|azp strings"));
        jwtRegistry.disableAzp(invalidDomainName);
    }

    function testRevert_disableAzp_tooManyParts() public {
        string
            memory invalidDomainName = "12345|https://example.com|client-id-12345|extra";
        vm.expectRevert(bytes("Invalid kid|iss|azp strings"));
        jwtRegistry.disableAzp(invalidDomainName);
    }

    function testRevert_disableAzp_emptyString() public {
        string memory invalidDomainName = "";
        vm.expectRevert(bytes("Invalid kid|iss|azp strings"));
        jwtRegistry.disableAzp(invalidDomainName);
    }

    function test_disableAzp() public {
        string memory domainName = "12345|https://example.com|client-id-12345";

        // Verify that client-id-12345 is whitelisted
        assertTrue(
            jwtRegistry.whitelistedClients("client-id-12345"),
            "Client should be whitelisted initially"
        );

        // Call disableAzp
        jwtRegistry.disableAzp(domainName);

        // Verify that client-id-12345 is no longer whitelisted
        assertFalse(
            jwtRegistry.whitelistedClients("client-id-12345"),
            "Client should not be whitelisted after disableAzp"
        );
    }
}
