pragma circom 2.1.6;

include "circomlib/circuits/comparators.circom";
include "circomlib/circuits/poseidon.circom";

// Verifies that a leaf exists in a Merkle tree
// Inputs:
// - leaf: The leaf value to verify
// - proof[height]: Array of proof elements
// - proofHelper[height]: Array of boolean values (0 for left, 1 for right)
// - root: The Merkle root to verify against
template MerkleTreeVerifier(height) {
    signal input leaf;
    signal input proof[height];
    signal input proofHelper[height];
    signal input root;
    signal output isValid;

    // Initialize the current hash with the leaf value
    signal computedHash[height + 1];
    computedHash[0] <== leaf;

    // For each level, compute the next hash
    component hasher[height];
    signal leftProof[height];
    signal leftComputed[height];
    signal rightProof[height];
    signal rightComputed[height];

    for (var i = 0; i < height; i++) {
        hasher[i] = Poseidon(2);
        
        // Break down the selector logic into separate constraints
        leftProof[i] <== proofHelper[i] * proof[i];
        leftComputed[i] <== (1 - proofHelper[i]) * computedHash[i];
        rightProof[i] <== (1 - proofHelper[i]) * proof[i];
        rightComputed[i] <== proofHelper[i] * computedHash[i];
        
        // Combine the inputs
        hasher[i].inputs[0] <== leftProof[i] + leftComputed[i];
        hasher[i].inputs[1] <== rightProof[i] + rightComputed[i];
        
        computedHash[i + 1] <== hasher[i].out;
    }

    // Check if computed root matches the provided root
    isValid <== IsEqual()([computedHash[height], root]);
}

