export class JWTVerificationError extends Error {
    constructor(message: string) {
        super(message);
        this.name = "JWTVerificationError";
    }
}

export class InvalidInputError extends Error {
    constructor(message: string) {
        super(message);
        this.name = "InvalidInputError";
    }
}
