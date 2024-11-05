/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable @typescript-eslint/no-explicit-any */
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
} from "@chakra-ui/react";
import { CheckCircleIcon, TimeIcon, WarningIcon } from "@chakra-ui/icons";
import styled from "@emotion/styled";
import axios from "axios";

declare global {
  interface Window {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
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

  const [stepStatuses, setStepStatuses] = useState([
    "idle",
    "idle",
    "idle",
    "idle",
  ]);
  const steps = [
    { title: "JWT Generation", description: "Generating JWT" },
    { title: "Proof Generation", description: "Starting proof generation" },
    { title: "Proof Complete", description: "Proof generation completed" },
    {
      title: "Submit to Contract",
      description: "Submitting proof to contract",
    },
  ];

  const handleCredentialResponse = async (response: any) => {
    try {
      const jwt = response.credential;
      console.log("JWT:", jwt);
      const decodedHeader = JSON.parse(
        Buffer.from(response.credential.split(".")[0], "base64").toString(
          "utf-8"
        )
      );
      const decodedPayload = JSON.parse(
        Buffer.from(response.credential.split(".")[1], "base64").toString(
          "utf-8"
        )
      );
      console.log("Decoded Header:", decodedHeader);
      console.log("Decoded Payload:", decodedPayload);
      setJwt(jwt);
      setError("");
      setStepStatuses(() => ["success", "idle", "idle"]);
      const pubkeys = await axios.get(
        "https://www.googleapis.com/oauth2/v3/certs"
      );
      const pubkey = pubkeys.data.keys.find(
        (key: any) => key.kid === decodedHeader.kid
      );

      const result = await generateProof(jwt, {
        n: pubkey.n,
        e: 65537,
      });
      if (result) {
        const { proof, pub_signals } = result;
        await submitProofToContract(
          proof,
          pub_signals,
          decodedHeader,
          decodedPayload
        );
      } else {
        throw new Error("Failed to generate proof");
      }
    } catch (error) {
      console.error("Error decoding JWT:", error);
      setError("Failed to process the sign-in response. Please try again.");
      setStepStatuses(() => ["failed", "idle", "idle"]);
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

  const generateProof = async (jwt: string, pubkey: any) => {
    try {
      setStepStatuses(() => ["success", "processing", "idle", "idle"]);
      const circuitInputs = await axios.post("/api/generateCircuitInputs", {
        jwt,
        pubkey,
        maxMessageLength: 1024,
      });
      const proverResponse = await axios.post("/api/proxyJwtProver", {
        input: circuitInputs.data,
      });
      setProof(proverResponse.data.proof);
      setStepStatuses(() => ["success", "success", "success", "idle"]);

      return {
        proof: proverResponse.data.proof,
        pub_signals: proverResponse.data.pub_signals,
      };
    } catch (error) {
      console.error("Error generating proof:", error);
      if (axios.isAxiosError(error) && error.response) {
        setError(
          `Failed to generate proof: ${error.response.data.message || error.message}`
        );
      } else {
        setError("Failed to generate proof. Please try again.");
      }
      setStepStatuses(() => ["success", "failed", "idle", "idle"]);
    }
  };

  const submitProofToContract = async (
    proof: any,
    pub_signals: any,
    header: any,
    payload: any
  ) => {
    try {
      setStepStatuses(() => ["success", "success", "success", "processing"]);
      console.log("Submitting proof to contract:", proof, pub_signals);
      const response = await axios.post("/api/submitProofToContract", {
        proof,
        pub_signals,
        header,
        payload,
      });
      console.log("Proof submitted to contract:", response.data);
      setStepStatuses(() => ["success", "success", "success", "success"]);
    } catch (error) {
      console.error("Error submitting proof to contract:", error);
      if (axios.isAxiosError(error) && error.response) {
        setError(
          `Failed to submit proof: ${error.response.data.message || error.message}`
        );
      } else {
        setError("Failed to submit proof to contract. Please try again.");
      }
      setStepStatuses(() => ["success", "success", "success", "failed"]);
    }
  };

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
            {stepStatuses[index] === "success" && <CheckCircleIcon mr={2} />}
            {stepStatuses[index] === "processing" && <TimeIcon mr={2} />}
            {stepStatuses[index] === "failed" && <WarningIcon mr={2} />}
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
                Welcome to JWT-Wallet! Follow these steps to get started:
              </Text>
              <StyledOrderedList>
                <StyledListItem>
                  <InstructionStep>Enter a command</InstructionStep> in the
                  input field below (e.g., &quot;Send 0.12 ETH to
                  0x1234...&quot;)
                </StyledListItem>
                <StyledListItem>
                  The <InstructionStep>Google Sign-In button</InstructionStep>{" "}
                  will become active once you&apos;ve entered a command
                </StyledListItem>
                <StyledListItem>
                  <InstructionStep>
                    Click the Google Sign-In button
                  </InstructionStep>{" "}
                  to authenticate and generate a JWT
                </StyledListItem>
                <StyledListItem>
                  <InstructionStep>Check the console</InstructionStep> for the
                  decoded JWT information
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
