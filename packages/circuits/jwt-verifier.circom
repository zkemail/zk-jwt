pragma circom 2.1.6;

include "circomlib/circuits/bitify.circom";
include "@zk-email/circuits/utils/array.circom";
include "@zk-email/circuits/lib/sha.circom";
include "@zk-email/circuits/lib/rsa.circom";

/**
 * @title JWTVerifier
 * @description A circuit template for verifying JSON Web Tokens (JWT) using RSA signatures.
 * This template computes the SHA256 hash of the JWT message and verifies the signature
 * against the provided RSA public key.
 *
 * @param n Number of bits per chunk the RSA key is split into. 
 * @param k Number of chunks the RSA key is split into. 
 * @param maxMessageLength Maximum length of the JWT message (header + payload).
 *
 * @input message[maxMessageLength] The JWT message to be verified, which includes the header and payload.
 * @input messageLength The length of the JWT message that is signed.
 * @input pubkey[k] The RSA public key split into k chunks, used for signature verification.
 * @input signature[k] The RSA signature split into k chunks, which is to be verified against the JWT message.
 *
 * @output sha[256] The SHA256 hash of the JWT message, computed for signature verification.
 */ 
template JWTVerifier(n, k, maxMessageLength) {
    signal input message[maxMessageLength]; // JWT message (header + payload)
    signal input messageLength; // Length of the message signed in the JWT
    signal input pubkey[k]; // RSA public key split into k chunks
    signal input signature[k]; // RSA signature split into k chunks

    assert(maxMessageLength % 64 == 0);
    assert(n * k > 2048); // to support 2048 bit RSA
    assert(n < (255 \ 2)); // for multiplication to fit in the field (255 bits)

    // Assert message length fits in ceil(log2(maxMessageLength))
    component n2bMessageLength = Num2Bits(log2Ceil(maxMessageLength));
    n2bMessageLength.in <== messageLength;

    // Assert message data after messageLength are zeros
    AssertZeroPadding(maxMessageLength)(message, messageLength);

    // Calculate SHA256 hash of the JWT message
    signal output sha[256] <== Sha256Bytes(maxMessageLength)(message, messageLength);

    // Pack SHA output bytes to int[] for RSA input message
    var rsaMessageSize = (256 + n) \ n; // Adjust based on RSA chunk size
    component rsaMessage[rsaMessageSize];
    for (var i = 0; i < rsaMessageSize; i++) {
        rsaMessage[i] = Bits2Num(n);
    }
    for (var i = 0; i < 256; i++) {
        rsaMessage[i \ n].in[i % n] <== sha[255 - i];
    }
    for (var i = 256; i < n * rsaMessageSize; i++) {
        rsaMessage[i \ n].in[i % n] <== 0;
    }

    // Verify RSA signature
    component rsaVerifier = RSAVerifier65537(n, k);
    for (var i = 0; i < rsaMessageSize; i++) {
        rsaVerifier.message[i] <== rsaMessage[i].out;
    }
    for (var i = rsaMessageSize; i < k; i++) {
        rsaVerifier.message[i] <== 0;
    }
    rsaVerifier.modulus <== pubkey;
    rsaVerifier.signature <== signature;
}


