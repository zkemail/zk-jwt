pragma circom 2.1.6;

/**
 * @title JWTVerifierWithAnonymousDomain
 * @description A circuit template that extends JWTVerifier to add anonymous domain verification.
 * This template verifies a JWT signature and ensures the email domain is part of an allowed set
 * using a Merkle tree, without revealing the specific domain.
 *
 * @param n Number of bits per chunk the RSA key is split into
 * @param k Number of chunks the RSA key is split into
 * @param maxMessageLength Maximum length of the JWT message (header + payload)
 * @param maxB64HeaderLength Maximum length of the Base64 encoded header
 * @param maxB64PayloadLength Maximum length of the Base64 encoded payload
 * @param maxAzpLength Maximum length of the "azp" value in the JWT payload
 * @param maxCommandLength Maximum length of the command in the nonce
 * @param anonymousDomainsTreeHeight Height of the Merkle tree containing allowed email domains
 *
 * @input message[maxMessageLength] The JWT message to be verified (header + payload)
 * @input messageLength The length of the JWT message that is signed
 * @input pubkey[k] The RSA public key split into k chunks
 * @input signature[k] The RSA signature split into k chunks
 * @input accountCode The account code to verify against the invitation code
 * @input codeIndex The index of the invitation code in the command
 * @input periodIndex The index of the period separating header and payload
 * @input jwtTypStartIndex The index of the "typ" claim in the header
 * @input jwtKidStartIndex The index of the "kid" claim in the header
 * @input issKeyStartIndex The index of the "iss" claim in the payload
 * @input issLength The length of the "iss" claim
 * @input iatKeyStartIndex The index of the "iat" claim
 * @input azpKeyStartIndex The index of the "azp" claim
 * @input azpLength The length of the "azp" claim
 * @input emailKeyStartIndex The index of the "email" claim
 * @input emailLength The length of the email
 * @input nonceKeyStartIndex The index of the "nonce" claim
 * @input commandLength The length of the command
 * @input emailDomainIndex The index of the domain in the email
 * @input emailDomainLength The length of the domain in the email
 * @input anonymousDomainsTreeRoot The root of the Merkle tree for allowed email domains
 * @input emailDomainPath[anonymousDomainsTreeHeight] The Merkle proof path for the email domain
 * @input emailDomainPathHelper[anonymousDomainsTreeHeight] Helper values for the Merkle proof
 *
 * @output kid The "kid" value from the header
 * @output iss[issFieldLength] The "iss" (issuer) value as an array of integers
 * @output publicKeyHash The Poseidon hash of the RSA public key
 * @output jwtNullifier A unique identifier derived from the JWT signature
 * @output timestamp The "iat" (issued at) timestamp value
 * @output maskedCommand[commandFieldLength] The command with sensitive info (code and email) removed
 * @output accountSalt A salt derived from email and account code
 * @output azp[azpFieldLength] The "azp" (authorized party) value as an array of integers
 * @output domainName[maxDomainFieldLength] The domain name extracted from the email
 * @output isCodeExist A boolean (0/1) indicating if a valid invitation code exists
 */
template JWTVerifierWithAnonymousDomain(
        n,
        k, 
        maxMessageLength, 
        maxB64HeaderLength, 
        maxB64PayloadLength, 
        maxAzpLength, 
        maxCommandLength,
        anonymousDomainsTreeHeight,
) {
    signal input message[maxMessageLength]; // JWT message (header + payload)
    signal input messageLength; // Length of the message signed in the JWT
    signal input pubkey[k]; // RSA public key split into k chunks
    signal input signature[k]; // RSA signature split into k chunks

    signal input accountCode;
    signal input codeIndex; // Index of the "invitation code" in the "command"

    signal input periodIndex; // Index of the period in the JWT message

    signal input jwtTypStartIndex; // Index of the "typ" in the JWT header
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
    signal input emailDomainIndex; // Index of the domain in the email
    signal input emailDomainLength; // Length of the domain in the email

    signal input anonymousDomainsTreeRoot; // Root of the Merkle tree for the email domains (Public)
    signal input emailDomainPath[anonymousDomainsTreeHeight]; // Path in the Merkle tree for the email domain
    signal input emailDomainPathHelper[anonymousDomainsTreeHeight]; // Helper for the path in the Merkle tree for the email domain

    component jwtVerifier = JWTVerifier(n, k, maxMessageLength, maxB64HeaderLength, maxB64PayloadLength, maxAzpLength, maxCommandLength);
    jwtVerifier.message <== message;
    jwtVerifier.messageLength <== messageLength;
    jwtVerifier.pubkey <== pubkey;
    jwtVerifier.signature <== signature;
    jwtVerifier.accountCode <== accountCode;
    jwtVerifier.codeIndex <== codeIndex;
    jwtVerifier.periodIndex <== periodIndex;
    jwtVerifier.jwtTypStartIndex <== jwtTypStartIndex;
    jwtVerifier.jwtKidStartIndex <== jwtKidStartIndex;
    jwtVerifier.issKeyStartIndex <== issKeyStartIndex;
    jwtVerifier.issLength <== issLength;
    jwtVerifier.iatKeyStartIndex <== iatKeyStartIndex;
    jwtVerifier.azpKeyStartIndex <== azpKeyStartIndex;
    jwtVerifier.azpLength <== azpLength;
    jwtVerifier.emailKeyStartIndex <== emailKeyStartIndex;
    jwtVerifier.emailLength <== emailLength;
    jwtVerifier.nonceKeyStartIndex <== nonceKeyStartIndex;
    jwtVerifier.commandLength <== commandLength;
    jwtVerifier.emailDomainIndex <== emailDomainIndex;
    jwtVerifier.emailDomainLength <== emailDomainLength;

    signal output kid;
    signal output iss[issFieldLength];
    signal output publicKeyHash;
    signal output jwtNullifier;
    signal output timestamp;
    signal output maskedCommand[commandFieldLength];
    signal output accountSalt;
    signal output azp[azpFieldLength];
    signal output domainName[maxDomainFieldLength];
    signal output isCodeExist;

    kid <== jwtVerifier.kid;
    iss <== jwtVerifier.iss;
    publicKeyHash <== jwtVerifier.publicKeyHash;
    jwtNullifier <== jwtVerifier.jwtNullifier;
    timestamp <== jwtVerifier.timestamp;
    maskedCommand <== jwtVerifier.maskedCommand;
    accountSalt <== jwtVerifier.accountSalt;
    azp <== jwtVerifier.azp;
    isCodeExist <== jwtVerifier.isCodeExist;

    // Generate the leaf of the Merkle tree for the email domain
    component domainHasher = PoseidonModular(maxDomainFieldLength);
    for (var i = 0; i < maxDomainFieldLength; i++) {
        domainHasher.in[i] <== jwtVerifier.domainName[i];
    }
    signal domainLeaf <== domainHasher.out;

    // Verify the email domain is in the Merkle tree
    component treeVerifier = MerkleTreeVerifier(anonymousDomainsTreeHeight);
    for (var i = 0; i < anonymousDomainsTreeHeight; i++) {
        treeVerifier.proof[i] <== emailDomainPath[i];
        treeVerifier.proofHelper[i] <== emailDomainPathHelper[i];
    }
    treeVerifier.root <== anonymousDomainsTreeRoot;
    treeVerifier.leaf <== domainLeaf;
    treeVerifier.isValid === 1;
}