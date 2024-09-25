pragma circom 2.1.6;

include "@zk-email/ether-email-auth-circom/src/utils/hex2int.circom";

/**
 * @title Hex2FieldModular
 * @notice Converts a hexadecimal string representation to a field element.
 * @dev This template assumes that the input length is even.
 *      It first converts the hex string to bytes, then combines these bytes into a single field element.
 *
 * @param n The number of hexadecimal characters in the input (must be even)
 *
 * @input in[n] An array of n signals, each representing a hexadecimal character (0-9, a-f, A-F)
 * @output out The resulting field element
 */
template Hex2FieldModular(n) {
    assert(n % 2 == 0);

    signal input in[n];
    signal output out;
    signal bytes[n / 2] <== Hex2Ints(n)(in);
    signal sums[n / 2 + 1];
    sums[0] <== 0;
    for(var i = 0; i < n / 2; i++) {
        sums[i+1] <== 256 * sums[i] + bytes[i];
    }
    out <== sums[n / 2];
}
