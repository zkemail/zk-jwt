pragma circom 2.1.6;

include "circomlib/circuits/comparators.circom";

/// @title FindRealMessageLength
/// @notice Finds the length of the real message in a padded array by locating the first occurrence of 128
/// @dev This template is specifically designed for Base64 encoded strings followed by SHA-256 padding.
///      It works because:
///      1. Base64 uses characters with ASCII values < 128
///      2. SHA-256 padding starts with 128 (10000000 in binary)
///      3. The first 128 encountered marks the end of the Base64 string and start of padding
/// @input in[maxLength] The padded message array
/// @input maxLength The maximum possible length of the padded message
/// @output realLength The length of the real message (before padding)
template FindRealMessageLength(maxLength) {
    signal input in[maxLength];
    signal output realLength;

    // Signal to track if we've found 128
    signal found[maxLength + 1];
    found[0] <== 0;

    // Signal to accumulate the length
    signal lengthAcc[maxLength + 1];
    lengthAcc[0] <== 0;

    signal is128[maxLength];

    // Iterate through the array
    for (var i = 0; i < maxLength; i++) {
        // Check if current element is 128
        is128[i] <== IsEqual()([in[i], 128]);

        // Update found signal
        found[i + 1] <== found[i] + is128[i] - found[i] * is128[i];

        // If 128 not found yet, increment length
        lengthAcc[i + 1] <== lengthAcc[i] + 1 - found[i + 1];
    }

    // The final accumulated length is our real message length
    realLength <== lengthAcc[maxLength];

    // Constraint to ensure 128 was really found
    found[maxLength] === 1;
}