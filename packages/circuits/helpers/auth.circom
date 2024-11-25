pragma circom 2.1.6;

include "circomlib/circuits/poseidon.circom";
include "@zk-email/circuits/utils/hash.circom";
include "@zk-email/zk-regex-circom/circuits/common/email_addr_regex.circom";
include "@zk-email/ether-email-auth-circom/src/regexes/invitation_code_with_prefix_regex.circom";
include "@zk-email/ether-email-auth-circom/src/utils/bytes2ints.circom";
include "@zk-email/ether-email-auth-circom/src/utils/hash_sign.circom";
include "@zk-email/ether-email-auth-circom/src/utils/account_salt.circom";

include "../utils/merkle-tree.circom";

template MaskEmailInCommand(maxCommandLength) {
    signal input command[maxCommandLength];
    
    signal output removedEmailAddr[maxCommandLength];

    // Check for email pattern and get mask
    signal emailAddrRegexOut, emailAddrRegexReveal[maxCommandLength];
    (emailAddrRegexOut, emailAddrRegexReveal) <== EmailAddrRegex(maxCommandLength)(command);

    // Mask the email
    for(var i = 0; i < maxCommandLength; i++) {
        removedEmailAddr[i] <== emailAddrRegexOut * emailAddrRegexReveal[i];
    }
}

template MaskCodeInCommand(maxCommandLength) {
    signal input command[maxCommandLength];

    signal output removedCode[maxCommandLength];
    signal output isCodeExist;

    // Check for code pattern and get mask
    signal prefixedCodeRegexOut, prefixedCodeRegexReveal[maxCommandLength];
    (prefixedCodeRegexOut, prefixedCodeRegexReveal) <== InvitationCodeWithPrefixRegex(maxCommandLength)(command);
    isCodeExist <== prefixedCodeRegexOut;

    // Mask the code
    for(var i = 0; i < maxCommandLength; i++) {
        removedCode[i] <== isCodeExist * prefixedCodeRegexReveal[i];
    }
}

template ComputeJWTNullifier(n, k) {
    signal input signature[k];
    signal output jwtNullifier;

    var k2ChunkedSize = k >> 1;
    if(k % 2 == 1) {
        k2ChunkedSize += 1;
    }

    signal signHash;
    signal signInts[k2ChunkedSize];
    (signHash, signInts) <== HashSign(n,k)(signature);
    jwtNullifier <== Poseidon(1)([signHash]);
}

template CalculateAccountSalt(maxEmailLength) {
    signal input email[maxEmailLength];
    signal input accountCode;
    
    signal output accountSalt;

    signal emailInts[compute_ints_size(maxEmailLength)];
    emailInts <== Bytes2Ints(maxEmailLength)(email);
    accountSalt <== AccountSalt(compute_ints_size(maxEmailLength))(emailInts, accountCode);
}

template VerifyAnonymousDomain(maxDomainFieldLength, anonymousDomainsTreeHeight) {
    signal input domainName[maxDomainFieldLength];
    signal input anonymousDomainsTreeRoot;
    signal input emailDomainPath[anonymousDomainsTreeHeight];
    signal input emailDomainPathHelper[anonymousDomainsTreeHeight];

    signal output isDomainIncluded;

    // Generate the leaf of the Merkle tree for the email domain
    component domainHasher = PoseidonModular(maxDomainFieldLength);
    for (var i = 0; i < maxDomainFieldLength; i++) {
        domainHasher.in[i] <== domainName[i];
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

    isDomainIncluded <== treeVerifier.isValid;
}