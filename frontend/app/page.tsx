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
    Breadcrumb,
    BreadcrumbItem,
    BreadcrumbLink,
    Icon,
} from "@chakra-ui/react";
import { CheckCircleIcon, TimeIcon, WarningIcon } from "@chakra-ui/icons";
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
    const [stepStatuses, setStepStatuses] = useState(["idle", "idle", "idle"]);

    const steps = [
        { title: "JWT Generation", description: "Generating JWT" },
        { title: "Proof Generation", description: "Starting proof generation" },
        { title: "Proof Complete", description: "Proof generation completed" },
    ];

    const { activeStep, setActiveStep } = useSteps({
        index: 0,
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
                        setStepStatuses((prev) => [
                            "success",
                            "success",
                            "success",
                        ]);
                    } else {
                        setStepStatuses((prev) => [
                            "success",
                            "failed",
                            "idle",
                        ]);
                    }
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
            setStepStatuses((prev) => ["success", "processing", "idle"]);

            setTimeout(() => {
                if (worker) {
                    worker.postMessage({ jwt: response.credential });
                }
            }, 2000);
        } catch (error) {
            console.error("Error decoding JWT:", error);
            setError(
                "Failed to process the sign-in response. Please try again."
            );
            setStepStatuses((prev) => ["failed", "idle", "idle"]);
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

    const renderBreadcrumb = () => (
        <Breadcrumb spacing="8px" separator=">">
            {steps.map((step, index) => (
                <BreadcrumbItem key={index}>
                    <BreadcrumbLink
                        color={
                            stepStatuses[index] === "success"
                                ? "green.500"
                                : stepStatuses[index] === "processing"
                                ? "blue.500"
                                : stepStatuses[index] === "failed"
                                ? "red.500"
                                : "gray.500"
                        }
                    >
                        {stepStatuses[index] === "success" && (
                            <CheckCircleIcon mr={2} />
                        )}
                        {stepStatuses[index] === "processing" && (
                            <TimeIcon mr={2} />
                        )}
                        {stepStatuses[index] === "failed" && (
                            <WarningIcon mr={2} />
                        )}
                        {stepStatuses[index] === "idle" && (
                            <CheckCircleIcon mr={2} opacity={0.5} />
                        )}
                        {step.title}
                    </BreadcrumbLink>
                </BreadcrumbItem>
            ))}
        </Breadcrumb>
    );

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
                            {renderBreadcrumb()}
                        </VStack>
                    </CardBody>
                </Card>
            </Box>
        </Container>
    );
}
