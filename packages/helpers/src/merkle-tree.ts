import { buildPoseidon } from "circomlibjs";

export class MerkleTree {
    private readonly levels: number;
    private readonly hashFn: any;
    private tree: bigint[][];
    private readonly zeros: bigint[];

    constructor(levels: number, leaves: bigint[], hashFn: any) {
        this.levels = levels;
        this.hashFn = (inputs: bigint[]) => {
            const hash = hashFn(inputs);
            return this.hashToInteger(hash);
        };

        // Initialize zeros array for padding
        this.zeros = [];
        this.zeros[0] = 0n;
        for (let i = 1; i <= levels; i++) {
            this.zeros[i] = this.hashFn([this.zeros[i - 1], this.zeros[i - 1]]);
        }

        this.tree = this.buildTree(leaves);
    }

    private hashToInteger(hash: Uint8Array): bigint {
        return BigInt("0x" + Buffer.from(hash).toString("hex"));
    }

    private buildTree(leaves: bigint[]): bigint[][] {
        const totalLeaves = 2 ** this.levels;
        const paddedLeaves = [...leaves];
        while (paddedLeaves.length < totalLeaves) {
            paddedLeaves.push(this.zeros[0]);
        }

        const tree: bigint[][] = [];
        tree[0] = paddedLeaves;

        for (let level = 1; level <= this.levels; level++) {
            tree[level] = [];
            for (let i = 0; i < tree[level - 1].length; i += 2) {
                tree[level].push(
                    this.hashFn([tree[level - 1][i], tree[level - 1][i + 1]])
                );
            }
        }

        return tree;
    }

    public getRoot(): bigint {
        return this.tree[this.levels][0];
    }

    public getProof(index: number): {
        proof: bigint[];
        pathIndices: number[];
    } {
        const proof: bigint[] = [];
        const pathIndices: number[] = [];

        let currentIndex = index;
        for (let i = 0; i < this.levels; i++) {
            const levelSize = this.tree[i].length;
            const siblingIndex =
                currentIndex % 2 === 0
                    ? Math.min(currentIndex + 1, levelSize - 1)
                    : currentIndex - 1;

            proof.push(this.tree[i][siblingIndex]);
            pathIndices.push(currentIndex % 2); // 0 for left, 1 for right

            currentIndex = Math.floor(currentIndex / 2);
        }

        return { proof, pathIndices };
    }

    public static async verifyProof(
        leaf: bigint,
        proof: bigint[],
        pathIndices: number[],
        root: bigint
    ): Promise<boolean> {
        const poseidon = await buildPoseidon();
        const hashToInteger = (hash: Uint8Array): bigint => {
            return BigInt("0x" + Buffer.from(hash).toString("hex"));
        };

        let currentHash = leaf;
        for (let i = 0; i < proof.length; i++) {
            const [left, right] =
                pathIndices[i] === 0
                    ? [currentHash, proof[i]]
                    : [proof[i], currentHash];
            const hashResult = poseidon([left, right]);
            currentHash = hashToInteger(hashResult);
        }

        return currentHash === root;
    }
}

// Helper function to create a new Merkle Tree
export async function createMerkleTree(
    levels: number,
    leaves: bigint[]
): Promise<MerkleTree> {
    const poseidon = await buildPoseidon();
    return new MerkleTree(levels, leaves, poseidon);
}

// Helper function to verify a proof
export async function verifyMerkleProof(
    leaf: bigint,
    proof: bigint[],
    pathIndices: number[],
    root: bigint
): Promise<boolean> {
    return MerkleTree.verifyProof(leaf, proof, pathIndices, root);
}
