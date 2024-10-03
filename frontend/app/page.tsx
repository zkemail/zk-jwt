"use client";

import { useState, useEffect } from "react";
import {
    Box,
    Card,
    CardBody,
    Container,
    Heading,
    Input,
    VStack,
    Text,
    OrderedList,
    ListItem,
    useSteps,
} from "@chakra-ui/react";
import styled from "@emotion/styled";

declare global {
    interface Window {
        google: any;
    }
}

const StyledListItem = styled(ListItem)`
    font-family: var(--font-geist-sans);
    font-size: 1rem;
    line-height: 1.5;
    margin-bottom: 0.5rem;
    color: #4a5568;
`;

const StyledOrderedList = styled(OrderedList)`
    padding-left: 1.5rem;
    margin-bottom: 1.5rem;
`;

const InstructionStep = styled.span`
    font-weight: 600;
    color: #2b6cb0;
`;

export default function Home() {
    const [command, setCommand] = useState("");
    const [jwt, setJwt] = useState("");
    const [error, setError] = useState("");
    const [proof, setProof] = useState(null);
    const [worker, setWorker] = useState<Worker | null>(null);
    const [currentStep, setCurrentStep] = useState(0);
    const [status, setStatus] = useState<string | null>(null);

    const steps = [
        { title: "JWT Generation", description: "Generating JWT" },
        { title: "Proof Generation", description: "Starting proof generation" },
        { title: "Proof Complete", description: "Proof generation completed" },
    ];

    const { activeStep, setActiveStep } = useSteps({
        index: currentStep,
        count: steps.length,
    });

    useEffect(() => {
        if (typeof window !== "undefined") {
            const w = new Worker(new URL("./proof.worker.ts", import.meta.url));
            setWorker(w);

            w.onmessage = (event) => {
                if (event.data.type === "log") {
                    console.log(event.data.message);
                } else if (event.data.type === "proof") {
                    if (event.data.proof.success) {
                        setProof(event.data.proof);
                        self.onmessage = async (event) => {
                            const { jwt } = event.data;

                            // Simulate proof generation (replace with actual circom proof generation)
                            await new Promise((resolve) =>
                                setTimeout(resolve, 2000)
                            );
                            self.postMessage({
                                type: "log",
                                message:
                                    "Proof Worker: Proof generation complete",
                            });

                            const proof = {
                                success: true,
                                data: "Simulated proof",
                            };

                            self.postMessage({ type: "proof", proof });
                        };
                        setStatus("Proof Generated");
                    } else {
                        setStatus("Proof Generation Failed");
                    }
                    setTimeout(() => setStatus(null), 3000);
                }
            };

            return () => {
                w.terminate();
            };
        }
    }, []);

    const handleCredentialResponse = (response: any) => {
        try {
            console.log("JWT:", response.credential);
            const decodedHeader = JSON.parse(
                Buffer.from(
                    response.credential.split(".")[0],
                    "base64"
                ).toString("utf-8")
            );
            const decodedPayload = JSON.parse(
                Buffer.from(
                    response.credential.split(".")[1],
                    "base64"
                ).toString("utf-8")
            );
            console.log("Decoded Header:", decodedHeader);
            console.log("Decoded Payload:", decodedPayload);
            setJwt(response.credential);
            setError("");
            setStatus("JWT Generated");

            setTimeout(() => {
                if (worker) {
                    console.log("Sending JWT to worker");
                    worker.postMessage({ jwt: response.credential });
                    console.log("JWT sent to worker");
                    setStatus("Generating Proof");
                }
            }, 2000);
        } catch (error) {
            console.error("Error decoding JWT:", error);
            setError(
                "Failed to process the sign-in response. Please try again."
            );
        }
    };

    useEffect(() => {
        if (window.google) {
            window.google.accounts.id.initialize({
                client_id:
                    "397234807794-fh6mhl0jppgtt0ak5cgikhlesbe8f7si.apps.googleusercontent.com",
                callback: handleCredentialResponse,
            });
            window.google.accounts.id.renderButton(
                document.getElementById("googleSignInButton"),
                { theme: "outline", size: "large" }
            );
        }
    }, []);

    useEffect(() => {
        if (window.google) {
            window.google.accounts.id.cancel();
            if (command) {
                window.google.accounts.id.initialize({
                    client_id:
                        "397234807794-fh6mhl0jppgtt0ak5cgikhlesbe8f7si.apps.googleusercontent.com",
                    callback: handleCredentialResponse,
                    nonce: command,
                });
                window.google.accounts.id.renderButton(
                    document.getElementById("googleSignInButton"),
                    { theme: "outline", size: "large" }
                );
            }
        }
    }, [command]);

    return (
        <Container maxW="container.md" centerContent>
            <Box padding={8} width="100%">
                <Heading
                    as="h1"
                    size="2xl"
                    textAlign="center"
                    mb={8}
                    color="blue.600"
                    fontFamily="var(--font-geist-sans)"
                    fontWeight="800"
                    letterSpacing="-0.05em"
                >
                    JWT-Wallet
                </Heading>
                <Card>
                    <CardBody>
                        <VStack spacing={6}>
                            <Text
                                fontSize="xl"
                                textAlign="center"
                                fontFamily="var(--font-geist-sans)"
                                fontWeight="600"
                                color="gray.700"
                            >
                                Welcome to JWT-Wallet! Follow these steps to get
                                started:
                            </Text>
                            <StyledOrderedList>
                                <StyledListItem>
                                    <InstructionStep>
                                        Enter a command
                                    </InstructionStep>{" "}
                                    in the input field below (e.g., "Send 0.12
                                    ETH to 0x1234...")
                                </StyledListItem>
                                <StyledListItem>
                                    The{" "}
                                    <InstructionStep>
                                        Google Sign-In button
                                    </InstructionStep>{" "}
                                    will become active once you've entered a
                                    command
                                </StyledListItem>
                                <StyledListItem>
                                    <InstructionStep>
                                        Click the Google Sign-In button
                                    </InstructionStep>{" "}
                                    to authenticate and generate a JWT
                                </StyledListItem>
                                <StyledListItem>
                                    <InstructionStep>
                                        Check the console
                                    </InstructionStep>{" "}
                                    for the decoded JWT information
                                </StyledListItem>
                            </StyledOrderedList>
                            <Input
                                placeholder="Enter your command here"
                                value={command}
                                onChange={(e) => setCommand(e.target.value)}
                                size="lg"
                                borderColor="blue.300"
                                _hover={{ borderColor: "blue.400" }}
                                _focus={{
                                    borderColor: "blue.500",
                                    boxShadow: "0 0 0 1px #3182ce",
                                }}
                                fontFamily="var(--font-geist-mono)"
                            />
                            <Box
                                id="googleSignInButton"
                                opacity={command ? 1 : 0.5}
                                pointerEvents={command ? "auto" : "none"}
                                transition="opacity 0.3s"
                            />
                            {status && (
                                <Box
                                    position="fixed"
                                    bottom="0"
                                    left="0"
                                    right="0"
                                    bg="blue.500"
                                    color="white"
                                    p={2}
                                    textAlign="center"
                                    fontFamily="var(--font-geist-sans)"
                                >
                                    {status}
                                </Box>
                            )}
                        </VStack>
                    </CardBody>
                </Card>
            </Box>
        </Container>
    );
}
