/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable @typescript-eslint/no-explicit-any */
'use client';

import { useState, useEffect } from 'react';
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
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  Accordion,
  AccordionItem,
  AccordionButton,
  AccordionPanel,
  AccordionIcon,
} from '@chakra-ui/react';
import { CheckCircleIcon, TimeIcon, WarningIcon } from '@chakra-ui/icons';
import styled from '@emotion/styled';
import axios from 'axios';

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

const DetailHeading = styled(Text)`
  font-family: var(--font-geist-sans);
  font-weight: 600;
  color: #2d3748;
  margin-bottom: 0.5rem;
`;

const DetailContent = styled(Text)`
  font-family: var(--font-geist-mono);
  font-size: 0.875rem;
  color: #4a5568;
  white-space: pre-wrap;
  word-break: break-all;
  background: #edf2f7;
  padding: 1rem;
  border-radius: 0.375rem;
`;

export default function Home() {
  const [command, setCommand] = useState('');
  const [jwt, setJwt] = useState('');
  const [error, setError] = useState('');
  const [proof, setProof] = useState<{ proof: any; pub_signals: any } | null>(null);
  const [txHash, setTxHash] = useState<string | null>(null);
  const [decodedJwt, setDecodedJwt] = useState<{ rawJwt: string; header: any; payload: any; signature: string } | null>(
    null,
  );

  const [stepStatuses, setStepStatuses] = useState(['idle', 'idle', 'idle', 'idle']);
  const steps = [
    { title: 'JWT Generation', description: 'Generating JWT' },
    { title: 'Proof Generation', description: 'Starting proof generation' },
    { title: 'Proof Complete', description: 'Proof generation completed' },
    {
      title: 'Submit to Contract',
      description: 'Submitting proof to contract',
    },
  ];

  const handleCredentialResponse = async (response: any) => {
    try {
      const jwt = response.credential;
      console.log('JWT:', jwt);
      const decodedHeader = JSON.parse(Buffer.from(response.credential.split('.')[0], 'base64').toString('utf-8'));
      const decodedPayload = JSON.parse(Buffer.from(response.credential.split('.')[1], 'base64').toString('utf-8'));
      console.log('Decoded Header:', decodedHeader);
      console.log('Decoded Payload:', decodedPayload);
      setDecodedJwt({
        rawJwt: jwt,
        header: decodedHeader,
        payload: decodedPayload,
        signature: jwt.split('.')[2],
      });
      setError('');
      setStepStatuses(() => ['success', 'idle', 'idle']);
      const pubkeys = await axios.get('https://www.googleapis.com/oauth2/v3/certs');
      const pubkey = pubkeys.data.keys.find((key: any) => key.kid === decodedHeader.kid);

      const result = await generateProof(jwt, {
        n: pubkey.n,
        e: 65537,
      });
      if (result) {
        const { proof, pub_signals } = result;
        await submitProofToContract(proof, pub_signals, decodedHeader, decodedPayload);
      } else {
        throw new Error('Failed to generate proof');
      }
    } catch (error) {
      console.error('Error decoding JWT:', error);
      setError('Failed to process the sign-in response. Please try again.');
      setStepStatuses(() => ['failed', 'idle', 'idle']);
    }
  };

  useEffect(() => {
    if (window.google) {
      window.google.accounts.id.initialize({
        client_id: '397234807794-fh6mhl0jppgtt0ak5cgikhlesbe8f7si.apps.googleusercontent.com',
        callback: handleCredentialResponse,
      });
      window.google.accounts.id.renderButton(document.getElementById('googleSignInButton'), {
        theme: 'outline',
        size: 'large',
      });
    }
  }, []);

  useEffect(() => {
    if (window.google) {
      window.google.accounts.id.cancel();
      if (command) {
        window.google.accounts.id.initialize({
          client_id: '397234807794-fh6mhl0jppgtt0ak5cgikhlesbe8f7si.apps.googleusercontent.com',
          callback: handleCredentialResponse,
          nonce: command,
        });
        window.google.accounts.id.renderButton(document.getElementById('googleSignInButton'), {
          theme: 'outline',
          size: 'large',
        });
      }
    }
  }, [command]);

  const generateProof = async (jwt: string, pubkey: any) => {
    try {
      setStepStatuses(() => ['success', 'processing', 'idle', 'idle']);
      const circuitInputs = await axios.post('/api/generateCircuitInputs', {
        jwt,
        pubkey,
        maxMessageLength: 1024,
      });
      const proverResponse = await axios.post('/api/proxyJwtProver', {
        input: circuitInputs.data,
      });
      setProof({ proof: proverResponse.data.proof, pub_signals: proverResponse.data.pub_signals });
      setStepStatuses(() => ['success', 'success', 'success', 'idle']);

      return {
        proof: proverResponse.data.proof,
        pub_signals: proverResponse.data.pub_signals,
      };
    } catch (error) {
      console.error('Error generating proof:', error);
      if (axios.isAxiosError(error) && error.response) {
        setError(`Failed to generate proof: ${error.response.data.message || error.message}`);
      } else {
        setError('Failed to generate proof. Please try again.');
      }
      setStepStatuses(() => ['success', 'failed', 'idle', 'idle']);
    }
  };

  const submitProofToContract = async (proof: any, pub_signals: any, header: any, payload: any) => {
    try {
      setStepStatuses(() => ['success', 'success', 'success', 'processing']);
      console.log('Submitting proof to contract:', proof, pub_signals);
      const response = await axios.post('/api/submitProofToContract', {
        proof,
        pub_signals,
        header,
        payload,
      });
      console.log('Proof submitted to contract:', response.data);
      setTxHash(response.data.transactionHash);
      setStepStatuses(() => ['success', 'success', 'success', 'success']);
    } catch (error) {
      console.error('Error submitting proof to contract:', error);
      if (axios.isAxiosError(error) && error.response) {
        setError(`Failed to submit proof: ${error.response.data.message || error.message}`);
      } else {
        setError('Failed to submit proof to contract. Please try again.');
      }
      setStepStatuses(() => ['success', 'success', 'success', 'failed']);
    }
  };

  const renderBreadcrumb = () => (
    <Breadcrumb spacing="8px" separator=">">
      {steps.map((step, index) => (
        <BreadcrumbItem key={index}>
          <BreadcrumbLink
            color={
              stepStatuses[index] === 'success'
                ? 'green.500'
                : stepStatuses[index] === 'processing'
                  ? 'blue.500'
                  : stepStatuses[index] === 'failed'
                    ? 'red.500'
                    : 'gray.500'
            }
          >
            {stepStatuses[index] === 'success' && <CheckCircleIcon mr={2} />}
            {stepStatuses[index] === 'processing' && <TimeIcon mr={2} />}
            {stepStatuses[index] === 'failed' && <WarningIcon mr={2} />}
            {stepStatuses[index] === 'idle' && <CheckCircleIcon mr={2} opacity={0.5} />}
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
          JWT-Demo
        </Heading>
        <Card>
          <CardBody>
            <VStack spacing={6}>
              <Text
                fontSize="xl"
                textAlign="center"
                fontFamily="var(--font-geist-sans)"
                fontWeight="600"
                color="gray.800"
              >
                Welcome to JWT-Demo! Follow these steps to get started:
              </Text>
              <StyledOrderedList>
                <StyledListItem>
                  Type your <InstructionStep>command</InstructionStep> below (e.g. &quot;Send 0.12 ETH to 0x1234...&quot;)
                </StyledListItem>
                <StyledListItem>
                  <InstructionStep>Google Sign-In</InstructionStep> activates after entering a command
                </StyledListItem>
                <StyledListItem>
                  Sign in with Google to <InstructionStep>generate your JWT</InstructionStep>
                </StyledListItem>
                <StyledListItem>
                  <InstructionStep>Proof generation</InstructionStep> begins automatically after JWT is created
                </StyledListItem>
                <StyledListItem>
                  Contract <InstructionStep>verifies</InstructionStep> the generated proof
                </StyledListItem>
                <StyledListItem>
                  Check the <InstructionStep>decoded JWT</InstructionStep>, <InstructionStep>proof</InstructionStep>,
                  and <InstructionStep>transaction</InstructionStep> below
                </StyledListItem>
              </StyledOrderedList>
              <Input
                placeholder="Enter your command here"
                value={command}
                onChange={(e) => setCommand(e.target.value)}
                size="lg"
                borderColor="blue.300"
                _hover={{ borderColor: 'blue.400' }}
                _focus={{
                  borderColor: 'blue.500',
                  boxShadow: '0 0 0 1px #3182ce',
                }}
                fontFamily="var(--font-geist-mono)"
              />
              <Box
                id="googleSignInButton"
                opacity={command ? 1 : 0.5}
                pointerEvents={command ? 'auto' : 'none'}
                transition="opacity 0.3s"
              />
              {renderBreadcrumb()}
            </VStack>
          </CardBody>
        </Card>

        <Accordion allowMultiple width="100%" display="flex" flexDirection="column">
          {decodedJwt && (
            <AccordionItem border="1px solid" borderColor="blue.100" borderRadius="md" mt={2} bg="gray.50">
              <h2>
                <AccordionButton py={3} px={4} _hover={{ bg: 'blue.100' }} borderRadius="md">
                  <Box as="span" flex="1" textAlign="left">
                    <Text color="blue.700">Decoded JWT</Text>
                  </Box>
                  <AccordionIcon />
                </AccordionButton>
              </h2>
              <AccordionPanel pb={6} px={4} bg="white">
                <VStack align="stretch" spacing={4}>
                  <Box>
                    <DetailHeading>Raw JWT</DetailHeading>
                    <DetailContent>{decodedJwt.rawJwt}</DetailContent>
                  </Box>
                  <Box>
                    <DetailHeading>Header</DetailHeading>
                    <DetailContent>{JSON.stringify(decodedJwt.header, null, 2)}</DetailContent>
                  </Box>
                  <Box>
                    <DetailHeading>Payload</DetailHeading>
                    <DetailContent>{JSON.stringify(decodedJwt.payload, null, 2)}</DetailContent>
                  </Box>
                  <Box>
                    <DetailHeading>Signature</DetailHeading>
                    <DetailContent>{decodedJwt.signature}</DetailContent>
                  </Box>
                </VStack>
              </AccordionPanel>
            </AccordionItem>
          )}

          {proof && (
            <AccordionItem border="1px solid" borderColor="purple.100" borderRadius="md" mt={2} bg="gray.50">
              <h2>
                <AccordionButton py={3} px={4} _hover={{ bg: 'purple.100' }} borderRadius="md">
                  <Box as="span" flex="1" textAlign="left">
                    <Text color="purple.700">Generated Proof</Text>
                  </Box>
                  <AccordionIcon />
                </AccordionButton>
              </h2>
              <AccordionPanel pb={6} px={4} bg="white">
                <DetailContent>{JSON.stringify(proof, null, 2)}</DetailContent>
              </AccordionPanel>
            </AccordionItem>
          )}

          {txHash && (
            <AccordionItem border="1px solid" borderColor="green.100" borderRadius="md" mt={2} bg="gray.50">
              <h2>
                <AccordionButton py={3} px={4} _hover={{ bg: 'green.100' }} borderRadius="md">
                  <Box as="span" flex="1" textAlign="left">
                    <Text color="green.700">Transaction</Text>
                  </Box>
                  <AccordionIcon />
                </AccordionButton>
              </h2>
              <AccordionPanel pb={6} px={4} bg="white">
                <DetailContent>
                  <a
                    href={`https://sepolia.basescan.org/tx/${txHash}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    style={{ color: '#3182ce', textDecoration: 'underline' }}
                  >
                    View on BaseScan
                  </a>
                </DetailContent>
              </AccordionPanel>
            </AccordionItem>
          )}
        </Accordion>
      </Box>
    </Container>
  );
}
