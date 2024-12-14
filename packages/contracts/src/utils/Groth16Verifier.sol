// Copyright 2017 Christian Reitwiessner
// Copyright 2019 OKIMS
// Copyright 2024 Codex
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
import "./Groth16.sol";

contract Groth16Verifier is IGroth16Verifier {
  uint256 private constant _P =
    21888242871839275222246405745257275088696311157297823662689037894645226208583;
  uint256 private constant _R =
    21888242871839275222246405745257275088548364400416034343698204186575808495617;

  VerifyingKey private _verifyingKey;

  struct VerifyingKey {
    G1Point alpha1;
    G2Point beta2;
    G2Point gamma2;
    G2Point delta2;
    G1Point[] ic;
  }

  constructor(VerifyingKey memory key) {
    _verifyingKey.alpha1 = key.alpha1;
    _verifyingKey.beta2 = key.beta2;
    _verifyingKey.gamma2 = key.gamma2;
    _verifyingKey.delta2 = key.delta2;
    for (uint i = 0; i < key.ic.length; i++) {
      _verifyingKey.ic.push(key.ic[i]);
    }
  }

  function _negate(G1Point memory point) private pure returns (G1Point memory) {
    return G1Point(point.x, (_P - point.y) % _P);
  }

  function _add(
    G1Point memory point1,
    G1Point memory point2
  ) private view returns (bool success, G1Point memory sum) {
    // Call the precompiled contract for addition on the alt_bn128 curve.
    // The call will fail if the points are not valid group elements:
    // https://eips.ethereum.org/EIPS/eip-196#exact-semantics

    uint256[4] memory input;
    input[0] = point1.x;
    input[1] = point1.y;
    input[2] = point2.x;
    input[3] = point2.y;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      success := staticcall(gas(), 6, input, 128, sum, 64)
    }
  }

  function _multiply(
    G1Point memory point,
    uint256 scalar
  ) private view returns (bool success, G1Point memory product) {
    // Call the precompiled contract for scalar multiplication on the alt_bn128
    // curve. The call will fail if the points are not valid group elements:
    // https://eips.ethereum.org/EIPS/eip-196#exact-semantics

    uint256[3] memory input;
    input[0] = point.x;
    input[1] = point.y;
    input[2] = scalar;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      success := staticcall(gas(), 7, input, 96, product, 64)
    }
  }

  function _checkPairing(
    G1Point memory a1,
    G2Point memory a2,
    G1Point memory b1,
    G2Point memory b2,
    G1Point memory c1,
    G2Point memory c2,
    G1Point memory d1,
    G2Point memory d2
  ) private view returns (bool success, uint256 outcome) {
    // Call the precompiled contract for pairing check on the alt_bn128 curve.
    // The call will fail if the points are not valid group elements:
    // https://eips.ethereum.org/EIPS/eip-197#specification

    uint256[24] memory input; // 4 pairs of G1 and G2 points
    uint256[1] memory output;

    input[0] = a1.x;
    input[1] = a1.y;
    input[2] = a2.x.imag;
    input[3] = a2.x.real;
    input[4] = a2.y.imag;
    input[5] = a2.y.real;

    input[6] = b1.x;
    input[7] = b1.y;
    input[8] = b2.x.imag;
    input[9] = b2.x.real;
    input[10] = b2.y.imag;
    input[11] = b2.y.real;

    input[12] = c1.x;
    input[13] = c1.y;
    input[14] = c2.x.imag;
    input[15] = c2.x.real;
    input[16] = c2.y.imag;
    input[17] = c2.y.real;

    input[18] = d1.x;
    input[19] = d1.y;
    input[20] = d2.x.imag;
    input[21] = d2.x.real;
    input[22] = d2.y.imag;
    input[23] = d2.y.real;

    // solhint-disable-next-line no-inline-assembly
    assembly {
      success := staticcall(gas(), 8, input, 768, output, 32)
    }
    return (success, output[0]);
  }

  function verify(
    Groth16Proof calldata proof,
    uint256[] memory input
  ) public view returns (bool success) {
    // Check amount of public inputs
    if (input.length + 1 != _verifyingKey.ic.length) {
      return false;
    }
    // Check that public inputs are field elements
    for (uint i = 0; i < input.length; i++) {
      if (input[i] >= _R) {
        return false;
      }
    }
    // Compute the linear combination
    G1Point memory combination = _verifyingKey.ic[0];
    for (uint i = 0; i < input.length; i++) {
      G1Point memory product;
      (success, product) = _multiply(_verifyingKey.ic[i + 1], input[i]);
      if (!success) {
        return false;
      }
      (success, combination) = _add(combination, product);
      if (!success) {
        return false;
      }
    }
    // Check the pairing
    uint256 outcome;
    (success, outcome) = _checkPairing(
      _negate(proof.a),
      proof.b,
      _verifyingKey.alpha1,
      _verifyingKey.beta2,
      combination,
      _verifyingKey.gamma2,
      proof.c,
      _verifyingKey.delta2
    );
    if (!success) {
      return false;
    }
    return outcome == 1;
  }
}