pragma circom 2.1.6;

function JWT_TYP_LENGTH() {
    // len("typ": "JWT")
    return 11;
}

function JWT_ALG_LENGTH() {
    // len("alg":"RS256")
    return 13;
}

function JWT_TYP() {
    // "typ":"JWT"
    return [34, 116, 121, 112, 34, 58, 34, 74, 87, 84, 34];
}

function JWT_ALG() {
    // "alg":"RS256"
    return [34, 97, 108, 103, 34, 58, 34, 82, 83, 50, 53, 54, 34];
}