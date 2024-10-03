/// <reference lib="webworker" />

self.onmessage = async (event: MessageEvent) => {
    const { jwt } = event.data;

    // Simulate proof generation (replace with actual circom proof generation)
    await new Promise((resolve) => setTimeout(resolve, 2000));
    self.postMessage({
        type: "log",
        message: "Proof Worker: Proof generation complete",
    });

    const proof = { success: true, data: "Simulated proof" };

    self.postMessage({ type: "proof", proof });
};
