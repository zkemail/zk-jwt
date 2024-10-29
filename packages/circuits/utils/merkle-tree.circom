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

    // For each level, compute the next hash based on the path
    for (var i = 0; i < height; i++) {
        component hasher = Poseidon(2);
        
        // If pathIndex is 0, proof element goes on right
        // If pathIndex is 1, proof element goes on left
        hasher.inputs[0] <== (1 - proofHelper[i]) * computedHash[i] + proofHelper[i] * proof[i];
        hasher.inputs[1] <== proofHelper[i] * computedHash[i] + (1 - proofHelper[i]) * proof[i];
        
        computedHash[i + 1] <== hasher.out;
    }

    // Check if computed root matches the provided root
    isValid <== IsEqual()(computedHash[height], root);
}

