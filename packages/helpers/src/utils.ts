import { Buffer } from "buffer";

/**
 * @description Split a JWT token into its header, payload, and signature components
 * @param jwt The JWT token as a string
 * @returns An array containing the header, payload, and signature as base64 encoded strings
 */
export function splitJWT(jwt: string): [string, string, string] {
    const parts = jwt.split(".");
    if (parts.length !== 3) {
        throw new Error(
            'Invalid JWT format. Expected 3 parts separated by "."'
        );
    }
    return [parts[0], parts[1], parts[2]];
}

/**
 * @description Converts a Base64 string to a bigint.
 * @param base64String The Base64-encoded string to convert.
 * @returns The corresponding bigint representation of the Base64 string.
 */
export function base64ToBigInt(base64String: string): bigint {
    return BigInt(`0x${Buffer.from(base64String, "base64").toString("hex")}`);
}
