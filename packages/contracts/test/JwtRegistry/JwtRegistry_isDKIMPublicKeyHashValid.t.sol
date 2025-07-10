// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import 'forge-std/Test.sol';
import 'forge-std/console.sol';
import { JwtRegistryTestBase } from './JwtRegistryBase.t.sol';

contract JwtRegistryTest_isDKIMPublicKeyHashValid is JwtRegistryTestBase {
  constructor() {}

  function setUp() public override {
    super.setUp();
  }

  function test_isDKIMPublicKeyHashValid_invalidKid() public view {
    string memory domainName = '54321|https://example.com|client-id-12345';
    bool res = jwtRegistry.isDKIMPublicKeyHashValid(domainName, publicKeyHash);
    assertFalse(res);
  }

  function test_isDKIMPublicKeyHashValid_invalidIss() public view {
    string memory domainName = '12345|https://example.xyz|client-id-12345';
    bool res = jwtRegistry.isDKIMPublicKeyHashValid(domainName, publicKeyHash);
    assertFalse(res);
  }

  function test_isDKIMPublicKeyHashValid_invalidAzp() public view {
    string memory domainName = '12345|https://example.com|client-id-54321';
    bool res = jwtRegistry.isDKIMPublicKeyHashValid(domainName, publicKeyHash);
    assertFalse(res);
  }

  function test_isDKIMPublicKeyHashValid() public view {
    string memory domainName = '12345|https://example.com|client-id-12345';
    bool res = jwtRegistry.isDKIMPublicKeyHashValid(domainName, publicKeyHash);
    assertTrue(res);
  }
}
