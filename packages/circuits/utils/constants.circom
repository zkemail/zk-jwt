pragma circom 2.1.6;

function JWT_TYP_LENGTH() {
    // len("typ": "JWT")
    return 11;
}

function JWT_ALG_LENGTH() {
    // len("alg":"RS256")
    return 13;
}

function AZP_KEY_LENGTH() {
    // len("azp":)
    return 6;
}

function COMMAND_LENGTH() {
    // len("command":)
    return 10;
}

function JWT_TYP() {
    // "typ":"JWT"
    return [34, 116, 121, 112, 34, 58, 34, 74, 87, 84, 34];
}

function JWT_ALG() {
    // "alg":"RS256"
    return [34, 97, 108, 103, 34, 58, 34, 82, 83, 50, 53, 54, 34];
}

function AZP_KEY() {
    // "azp":
    return [34, 97, 122, 112, 34, 58];
}

function COMMAND() {
    // "command":
    return [34, 99, 111, 109, 109, 97, 110, 100, 34, 58];
}