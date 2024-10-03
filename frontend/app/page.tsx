"use client";

import { useState, useEffect } from "react";
import {
    Box,
    Button,
    Card,
    CardBody,
    Container,
    Heading,
    Input,
    VStack,
    Text,
} from "@chakra-ui/react";

declare global {
    interface Window {
        google: any;
    }
}

export default function Home() {
    const [command, setCommand] = useState("");
    const [jwt, setJwt] = useState("");
    const [error, setError] = useState("");

    useEffect(() => {
        const initializeGoogleSignIn = () => {
            if (window.google) {
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
                window.google.accounts.id.prompt();
            }
        };

        if (document.readyState === "complete") {
            initializeGoogleSignIn();
        } else {
            window.addEventListener("load", initializeGoogleSignIn);
            return () =>
                window.removeEventListener("load", initializeGoogleSignIn);
        }
    }, [command]);

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

    const handleSignIn = () => {
        if (command) {
            try {
                window.google.accounts.id.prompt((notification: any) => {
                    if (
                        notification.isNotDisplayed() ||
                        notification.isSkippedMoment()
                    ) {
                        console.error(
                            "Google Sign-In prompt failed to display"
                        );
                        setError(
                            "Failed to display Google Sign-In prompt. Please try again."
                        );
                    }
                });
            } catch (error) {
                console.error("Error prompting Google Sign-In:", error);
                setError(
                    "Failed to initiate Google Sign-In. Please try again."
                );
            }
        } else {
            setError("Please enter a command before signing in.");
        }
    };

    return (
        <Container centerContent>
            <Box padding={4}>
                <Heading as="h1" size="xl" textAlign="center" mb={8}>
                    JWT-Wallet
                </Heading>
                <Card>
                    <CardBody>
                        <VStack spacing={4}>
                            <Input
                                placeholder="Send 0.12 ETH to <address>"
                                value={command}
                                onChange={(e) => setCommand(e.target.value)}
                            />
                            <div id="googleSignInButton"></div>
                            {error && <Text color="red.500">{error}</Text>}
                            {jwt && (
                                <Text>
                                    JWT generated and logged to console. Check
                                    developer tools.
                                </Text>
                            )}
                        </VStack>
                    </CardBody>
                </Card>
            </Box>
        </Container>
    );
}
