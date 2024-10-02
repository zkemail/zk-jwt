pragma circom 2.1.6;

include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/poseidon.circom";
include "@zk-email/circuits/utils/array.circom";
include "@zk-email/circuits/utils/constants.circom";
include "@zk-email/circuits/utils/hash.circom";
include "@zk-email/circuits/lib/sha.circom";
include "@zk-email/circuits/lib/rsa.circom";
include "@zk-email/circuits/lib/base64.circom";
include "@zk-email/circuits/helpers/reveal-substring.circom";
include "@zk-email/ether-email-auth-circom/src/utils/bytes2ints.circom";
include "@zk-email/ether-email-auth-circom/src/utils/digit2int.circom";
include "@zk-email/ether-email-auth-circom/src/utils/hash_sign.circom";
include "@zk-email/ether-email-auth-circom/src/utils/account_salt.circom";
include "@zk-email/ether-email-auth-circom/src/regexes/invitation_code_with_prefix_regex.circom";
include "@zk-email/zk-regex-circom/circuits/common/email_addr_regex.circom";
include "./utils/array.circom";
include "./utils/bytes.circom";
include "./utils/constants.circom";
include "./utils/hex2int.circom";

/**
 * @title JWTVerifier
 * @description A circuit template for verifying JSON Web Tokens (JWT) using RSA signatures.
 * This template computes the SHA256 hash of the JWT message and verifies the signature
 * against the provided RSA public key.
 *
 * @param n Number of bits per chunk the RSA key is split into. 
 * @param k Number of chunks the RSA key is split into. 
 * @param maxMessageLength Maximum length of the JWT message (header + payload).
 * @param maxB64HeaderLength Maximum length of the Base64 encoded header.
 * @param maxB64PayloadLength Maximum length of the Base64 encoded payload.
 * @param azpLength Length of the "azp" value in the JWT payload.
 * @param maxCommandLength Maximum length of the command in the nonce.
 *
 * @input message[maxMessageLength] The JWT message to be verified, which includes the header and payload.
 * @input messageLength The length of the JWT message that is signed.
 * @input pubkey[k] The RSA public key split into k chunks, used for signature verification.
 * @input signature[k] The RSA signature split into k chunks, which is to be verified against the JWT message.
 *
 * @output sha[256] The SHA256 hash of the JWT message, computed for signature verification.
 */ 
template JWTVerifier(
        n,
        k, 
        maxMessageLength, 
        maxB64HeaderLength, 
        maxB64PayloadLength, 
        maxAzpLength, 
        maxCommandLength
    ) {
 
    signal input message[maxMessageLength]; // JWT message (header + payload)
    signal input messageLength; // Length of the message signed in the JWT
    signal input pubkey[k]; // RSA public key split into k chunks
    signal input signature[k]; // RSA signature split into k chunks

    signal input accountCode;
    signal input codeIndex; // Index of the "invitation code" in the "command"

    signal input periodIndex; // Index of the period in the JWT message

    signal input jwtTypStartIndex; // Index of the "typ" in the JWT header
    signal input jwtAlgStartIndex; // Index of the "alg" in the JWT header
    signal input jwtKidStartIndex; // Index of the "kid" in the JWT header

    signal input issKeyStartIndex; // Index of the "iss" key in the JWT payload
    signal input issLength; // Length of the "iss" in the JWT payload
    signal input iatKeyStartIndex; // Index of the "iat" key in the JWT payload
    signal input azpKeyStartIndex; // Index of the "azp" (Authorized party) key in the JWT payload
    signal input azpLength; // Length of the "azp" (Authorized party) in the JWT payload
    signal input emailKeyStartIndex; // Index of the "email" key in the JWT payload
    signal input emailLength; // Length of the "email" in the JWT payload
    signal input nonceKeyStartIndex; // Index of the "nonce" key in the JWT payload
    signal input commandLength; // Length of the "command" in the "nonce" key in the JWT payload

    assert(maxMessageLength % 64 == 0);
    assert(n * k > 2048); // to support 2048 bit RSA
    assert(n < (255 \ 2)); // for multiplication to fit in the field (255 bits)

    // Ensure maxB64HeaderLength and maxB64PayloadLength are multiples of 4
    // Base64 encoding always produces output in multiples of 4 characters
    assert(maxB64HeaderLength % 4 == 0); 
    assert(maxB64PayloadLength % 4 == 0); 

    var commandFieldLength = compute_ints_size(maxCommandLength);
    var azpFieldLength = compute_ints_size(maxAzpLength);
    var issLen = ISSUER_MAX_BYTES();
    var issFieldLength = compute_ints_size(issLen);

    signal output kid;
    signal output iss[issFieldLength];
    signal output publicKeyHash;
    signal output jwtNullifier;
    signal output timestamp;
    signal output maskedCommand[commandFieldLength];
    signal output accountSalt;
    signal output azp[azpFieldLength];
    signal output isCodeExist;

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

    // Calculate the pubkey hash
    publicKeyHash <== PoseidonLarge(n, k)(pubkey);

    /// Calculate the JWT nullifier
    var k2ChunkedSize = k >> 1;
    if(k % 2 == 1) {
        k2ChunkedSize += 1;
    }
    signal signHash;
    signal signInts[k2ChunkedSize];
    (signHash, signInts) <== HashSign(n,k)(signature);
    jwtNullifier <== Poseidon(1)([signHash]);

    // Assert that period exists at periodIndex
    signal period <== ItemAtIndex(maxMessageLength)(message, periodIndex);
    period === 46;

    // Assert that period is unique
    signal periodCount <== CountCharOccurrences(maxMessageLength)(message, 46);
    periodCount === 1;

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

    // Verify if the key `kid` in the header is unique
    var kidKeyLength = JWT_KID_KEY_LENGTH();
    var kidKey[kidKeyLength] = JWT_KID_KEY();
    signal kidKeyMatch[kidKeyLength] <== RevealSubstring(maxHeaderLength, kidKeyLength, 1)(header, jwtKidStartIndex, kidKeyLength);
    for (var i = 0; i < kidKeyLength; i++) {
        kidKeyMatch[i] === kidKey[i];
    }

    // Reveal the kid in the header
    signal kidStartIndex <== jwtKidStartIndex + kidKeyLength + 1;
    var kidLength = JWT_KID_LENGTH();
    signal kidBytes[kidLength] <== RevealSubstring(maxHeaderLength, kidLength, 0)(header, kidStartIndex, kidLength);
    kid <== Hex2FieldModular(kidLength)(kidBytes);

    // Verify if the key `iss` in the payload is unique
    var issKeyLength = ISS_KEY_LENGTH();
    var issKey[issKeyLength] = ISS_KEY();
    signal issKeyMatch[issKeyLength] <== RevealSubstring(maxPayloadLength, issKeyLength, 1)(payload, issKeyStartIndex, issKeyLength);
    for (var i = 0; i < issKeyLength; i++) {
        issKeyMatch[i] === issKey[i];
    }   

    // Reveal the iss in the payload
    signal issStartIndex <== issKeyStartIndex + issKeyLength + 1;
    signal issMatch[issLen] <== RevealSubstring(maxPayloadLength, issLen, 0)(payload, issStartIndex, issLength);
    iss <== Bytes2Ints(issLen)(issMatch);

    // Verify if the key `iat` in the payload is unique
    var iatKeyLength = IAT_KEY_LENGTH();
    var iatKey[iatKeyLength] = IAT_KEY();
    signal iatKeyMatch[iatKeyLength] <== RevealSubstring(maxPayloadLength, iatKeyLength, 1)(payload, iatKeyStartIndex, iatKeyLength);
    for (var i = 0; i < iatKeyLength; i++) {
        iatKeyMatch[i] === iatKey[i];
    }

    // Reveal the iat in the payload
    var iatLength = TIMESTAMP_LENGTH();
    signal iatStartIndex <== iatKeyStartIndex + iatKeyLength;
    signal iatMatch[iatLength] <== RevealSubstring(maxPayloadLength, iatLength, 0)(payload, iatStartIndex, iatLength);
    timestamp <== Digit2Int(iatLength)(iatMatch);

    // Verify if the key `azp` in the payload is unique
    var azpKeyLength = AZP_KEY_LENGTH();
    var azpKey[azpKeyLength] = AZP_KEY();
    signal azpKeyMatch[azpKeyLength] <== RevealSubstring(maxPayloadLength, azpKeyLength, 1)(payload, azpKeyStartIndex, azpKeyLength);
    for (var i = 0; i < azpKeyLength; i++) {
        azpKeyMatch[i] === azpKey[i];
    }

    // Reveal the azp in the payload
    signal azpStartIndex <== azpKeyStartIndex + azpKeyLength + 1;
    signal azpMatch[maxAzpLength] <== RevealSubstring(maxPayloadLength, maxAzpLength, 0)(payload, azpStartIndex, azpLength);
    azp <== Bytes2Ints(maxAzpLength)(azpMatch);

    // Verify if the key `email` in the payload is unique
    var emailKeyLength = EMAIL_KEY_LENGTH();
    var emailKey[emailKeyLength] = EMAIL_KEY();
    signal emailKeyMatch[emailKeyLength] <== RevealSubstring(maxPayloadLength, emailKeyLength, 1)(payload, emailKeyStartIndex, emailKeyLength);
    for (var i = 0; i < emailKeyLength; i++) {
        emailKeyMatch[i] === emailKey[i];
    }

    // Reveal the email in the payload
    var maxEmailLength = EMAIL_ADDR_MAX_BYTES();
    signal emailStartIndex <== emailKeyStartIndex + emailKeyLength + 1;
    signal email[maxEmailLength] <== RevealSubstring(maxPayloadLength, maxEmailLength, 0)(payload, emailStartIndex, emailLength);

    // Calculate account salt using email
    var numEmailInts = compute_ints_size(maxEmailLength);
    signal emailInts[numEmailInts] <== Bytes2Ints(maxEmailLength)(email);
    accountSalt <== AccountSalt(numEmailInts)(emailInts, accountCode);

    // Verify if the key `nonce` in the payload is unique
    var nonceKeyLength = NONCE_LENGTH();
    var nonceKey[nonceKeyLength] = NONCE();
    signal nonceKeyMatch[nonceKeyLength] <== RevealSubstring(maxPayloadLength, nonceKeyLength, 1)(payload, nonceKeyStartIndex, nonceKeyLength);
    for (var i = 0; i < nonceKeyLength; i++) {
        nonceKeyMatch[i] === nonceKey[i];
    }

    // Reveal the command in the nonce
    signal commandStartIndex <== nonceKeyStartIndex + nonceKeyLength + 1;
    signal command[maxCommandLength] <== RevealSubstring(maxPayloadLength, maxCommandLength, 0)(payload, commandStartIndex, commandLength);

    // Check if the command in the nonce has a valid invitation code and remove the prefix if it exists
    signal prefixedCodeRegexOut, prefixedCodeRegexReveal[maxCommandLength];
    (prefixedCodeRegexOut, prefixedCodeRegexReveal) <== InvitationCodeWithPrefixRegex(maxCommandLength)(command);
    isCodeExist <== IsZero()(prefixedCodeRegexOut-1);
    signal removedCode[maxCommandLength];
    for(var i = 0; i < maxCommandLength; i++) {
        removedCode[i] <== isCodeExist * prefixedCodeRegexReveal[i];
    }

    // Check if the command in the nonce has a valid email address and remove the email address if it exists
    signal emailAddrRegexOut, emailAddrRegexReveal[maxCommandLength];
    (emailAddrRegexOut, emailAddrRegexReveal) <== EmailAddrRegex(maxCommandLength)(command);
    signal isEmailAddrExist <== IsZero()(emailAddrRegexOut-1);
    signal removedEmailAddr[maxCommandLength];
    for(var i = 0; i < maxCommandLength; i++) {
        removedEmailAddr[i] <== isEmailAddrExist * emailAddrRegexReveal[i];
    }

    // Mask the command with the code and email address
    signal maskedCommandBytes[maxCommandLength];
    for(var i = 0; i < maxCommandLength; i++) {
        maskedCommandBytes[i] <== command[i] - removedCode[i] - removedEmailAddr[i];
    }
    maskedCommand <== Bytes2Ints(maxCommandLength)(maskedCommandBytes);

    // Extract the invitation code from the command
    var invitationCodeLen = INVITATION_CODE_LENGTH();
    assert(invitationCodeLen < maxCommandLength);
    signal revealedCode[invitationCodeLen] <== RevealSubstring(maxCommandLength, invitationCodeLen, 0)(command, codeIndex, invitationCodeLen);
    signal invitationCodeHex[invitationCodeLen];
    for (var i = 0; i < invitationCodeLen; i++) {
        invitationCodeHex[i] <== isCodeExist * revealedCode[i] + (1 - isCodeExist) * 48;
    }

    // Verify the invitation code is equal to the account code
    signal embeddedAccountCode <== Hex2FieldModular(invitationCodeLen)(invitationCodeHex);
    isCodeExist * (embeddedAccountCode - accountCode) === 0;
}