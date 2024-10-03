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
    Alert,
    AlertIcon,
    AlertTitle,
    AlertDescription,
    Flex,
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
                            {error && (
                                <Text
                                    color="red.500"
                                    fontWeight="bold"
                                    fontFamily="var(--font-geist-sans)"
                                >
                                    {error}
                                </Text>
                            )}
                            {jwt && (
                                <Alert status="success" borderRadius="md">
                                    <AlertIcon />
                                    <AlertTitle
                                        mr={2}
                                        fontFamily="var(--font-geist-sans)"
                                    >
                                        Success!
                                    </AlertTitle>
                                    <AlertDescription fontFamily="var(--font-geist-sans)">
                                        JWT generated and logged to console.
                                        Check developer tools.
                                    </AlertDescription>
                                </Alert>
                            )}
                        </VStack>
                    </CardBody>
                </Card>
            </Box>
        </Container>
    );
}
