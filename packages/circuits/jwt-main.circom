pragma circom 2.1.6;

include "./jwt-auth.circom";

// Concrete entrypoint circuit instantiating the JWTAuth template
// Parameters chosen to support RSA-2048 with n=121 bits per chunk and k=17 chunks,
// and reasonable defaults for JWT sizes and claim limits
// maxMessageLength must be a multiple of 64; Base64 lengths must be multiples of 4
component main = JWTAuth(121, 17, 1024, 128, 896, 64, 256);


