// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

struct G1Point {
  uint256 x;
  uint256 y;
}

// A field element F_{p^2} encoded as `real + i * imag`.
// We chose to not represent this as an array of 2 numbers, because both Circom
// and Ethereum EIP-197 encode to an array, but with conflicting encodings.
struct Fp2Element {
  uint256 real;
  uint256 imag;
}

struct G2Point {
  Fp2Element x;
  Fp2Element y;
}

struct Groth16Proof {
  G1Point a;
  G2Point b;
  G1Point c;
}

interface IGroth16Verifier {
  function verify(
    Groth16Proof calldata proof,
    uint256[] calldata pubSignals
  ) external view returns (bool);
}