pragma circom 2.1.6;

include "circomlib/circuits/bitify.circom";
include "@zk-email/circuits/utils/array.circom";
include "@zk-email/circuits/lib/sha.circom";
include "@zk-email/circuits/lib/rsa.circom";
include "@zk-email/circuits/lib/base64.circom";
include "@zk-email/circuits/helpers/reveal-substring.circom";
include "./utils/array.circom";
include "./utils/bytes.circom";
include "./utils/constants.circom";

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
template JWTVerifier(n, k, maxMessageLength, maxB64HeaderLength, maxB64PayloadLength) {
    signal input message[maxMessageLength]; // JWT message (header + payload)
    signal input messageLength; // Length of the message signed in the JWT
    signal input pubkey[k]; // RSA public key split into k chunks
    signal input signature[k]; // RSA signature split into k chunks

    signal input periodIndex; // Index of the period in the JWT message

    signal input jwtTypStartIndex; // Index of the "typ" in the JWT header
    signal input jwtAlgStartIndex; // Index of the "alg" in the JWT header
    signal input commandStartIndex; // Index of the key `command` in the JWT payload

    assert(maxMessageLength % 64 == 0);
    assert(n * k > 2048); // to support 2048 bit RSA
    assert(n < (255 \ 2)); // for multiplication to fit in the field (255 bits)

    // Ensure maxB64HeaderLength and maxB64PayloadLength are multiples of 4
    // Base64 encoding always produces output in multiples of 4 characters
    assert(maxB64HeaderLength % 4 == 0); 
    assert(maxB64PayloadLength % 4 == 0); 

    // Assert message length fits in ceil(log2(maxMessageLength))
    component n2bMessageLength = Num2Bits(log2Ceil(maxMessageLength));
    n2bMessageLength.in <== messageLength;

    // Assert message data after messageLength are zeros
    AssertZeroPadding(maxMessageLength)(message, messageLength);

    // Calculate SHA256 hash of the JWT message
    signal sha[256] <== Sha256Bytes(maxMessageLength)(message, messageLength);

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

    // Assert that period exists at periodIndex
    // TODO: Do we need to prove that it is the only period in the message?
    signal period <== ItemAtIndex(maxMessageLength)(message, periodIndex);
    period === 46;

    // Find the real message length
    signal realMessageLength <== FindRealMessageLength(maxMessageLength)(message);

    // Calculate the length of the Base64 encoded header and payload
    signal b64HeaderLength <== periodIndex;
    signal b64PayloadLength <== realMessageLength - b64HeaderLength - 1;

    // Extract the Base64 encoded header and payload from the message
    signal b64Header[maxB64HeaderLength] <== SelectSubArrayBase64(maxMessageLength, maxB64HeaderLength)(message, 0, b64HeaderLength);
    signal b64Payload[maxB64PayloadLength] <== SelectSubArrayBase64(maxMessageLength, maxB64PayloadLength)(message, b64HeaderLength + 1, b64PayloadLength);

    // Calculate the maximum length of the decoded header and payload
    var maxHeaderLength = (maxB64HeaderLength * 3) \ 4;
    var maxPayloadLength = (maxB64PayloadLength * 3) \ 4;

    // Decode the Base64 encoded header and payload
    signal header[maxHeaderLength] <== Base64Decode(maxHeaderLength)(b64Header);
    signal payload[maxPayloadLength] <== Base64Decode(maxPayloadLength)(b64Payload);

    // Verify if the typ in the header is "JWT"
    var typLength = JWT_TYP_LENGTH();
    var typ[typLength] = JWT_TYP();
    signal typMatch[typLength] <== RevealSubstring(maxHeaderLength, typLength, 0)(header, jwtTypStartIndex, typLength);
    for (var i = 0; i < typLength; i++) {
        typMatch[i] === typ[i];
    }

    // Verify if the alg in the header is "RS256"
    var algLength = JWT_ALG_LENGTH();
    var alg[algLength] = JWT_ALG();
    signal algMatch[algLength] <== RevealSubstring(maxHeaderLength, algLength, 0)(header, jwtAlgStartIndex, algLength);
    for (var i = 0; i < algLength; i++) {
        algMatch[i] === alg[i];
    }

    // Verify if `command` key exists in the payload
    var commandLength = COMMAND_LENGTH();
    var command[commandLength] = COMMAND();
    signal commandMatch[commandLength] <== RevealSubstring(maxPayloadLength, commandLength, 1)(payload, commandStartIndex, commandLength);
    for (var i = 0; i < commandLength; i++) {
        commandMatch[i] === command[i];
    }
}