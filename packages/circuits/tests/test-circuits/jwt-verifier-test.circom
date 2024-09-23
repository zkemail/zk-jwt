pragma circom 2.1.6;

include "../../jwt-verifier.circom";

component main { public [ pubkey ] } = JWTVerifier(121, 17, 384, 64, 256, 14, 128);
