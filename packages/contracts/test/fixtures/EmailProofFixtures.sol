// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {EmailProof} from "../../src/utils/JwtVerifier.sol";

library EmailProofFixtures {
    function getCase1SignHash() internal pure returns (EmailProof memory) {
        return EmailProof({
            domainName: "ba63b436836a939b795b4122d3f4d0d225d1c700|https://accounts.google.com|397234807794-fh6mhl0jppgtt0ak5cgikhlesbe8f7si.apps.googleusercontent.com",
            publicKeyHash: 0x1ee2151ef3e5f71eaf1a5cec05a02a5c9d7f1580dfe758ec2b8c706de434f36c,
            timestamp: 1755073350,
            maskedCommand: "signHash 0x8e6a49eec91c57b5722c6efe4f9c0b6d5365cc6713a6f8859d090df5a5c311cb",
            emailNullifier: 0x0f4b2eb6b06b5ce1df3e9aa727f994960cafa01ea7d96985594e1c98a17ccc79,
            accountSalt: 0x1f60c572a4535fa634fba6604d3dda7be3a4192b95ff46e79d8c7ec3649cf63b,
            isCodeExist: false,
            proof: hex"1afedcbb2e48c508939ecff471f038475c6219adb8fee1b2002673b7dc3158de2bc1c58173e40f1dae56162f0519af295fc021d7007c20f340611e1ae0ddb37b10e68565216952e06b00ba8a6c27d8cc3ab660d41c69222b1ca47c195120c73325edb04152502be63462908fbefd1bd8fcdcc7427d1c2329735a8c713cc887d912f80132e5f6457ce5b10c69b75f829a59f2073fe77270785bcc7a53ab72c5d007bb493de7ed80ce4bc0563af15fc91d0f5d01dc5493c833e11351e6fac1685d11a8a104abfa809dccee74a4b9a7ad12fe8e858eeda83a09e0350f338e6461c1158980398447ccc82eae1a5838553f37f5783fdd3188f768b05c7ae7dff1fa61"
        });
    }

    function getCase2SendETH() internal pure returns (EmailProof memory) {
        return EmailProof({
            domainName: "ba63b436836a939b795b4122d3f4d0d225d1c700|https://accounts.google.com|397234807794-fh6mhl0jppgtt0ak5cgikhlesbe8f7si.apps.googleusercontent.com",
            publicKeyHash: 0x1ee2151ef3e5f71eaf1a5cec05a02a5c9d7f1580dfe758ec2b8c706de434f36c,
            timestamp: 1755073560,
            maskedCommand: "Send 0.12 ETH to 0xB3d489a5eF3003cB41BCd3177B087244c3F59e15",
            emailNullifier: 0x01e7fe34fe6a0c8fc9ac6207dc1d799ba600c1eb5d81982eb5e4d086d0c70b0f,
            accountSalt: 0x0829ca2e6f0056dd6ecab95c7bb7b065aebe90cc16b34a86cbdf7467be933831,
            isCodeExist: false,
            proof: hex"223b8d15f0f5ce8b35648c191f96d9952d9b58955984d882f6c053968eece04d1adc1a1eb0393f03c162a7f5f71475688ec9ad7485e0e122258a73e37d990a6208d116f92c8e4cd4dbccc812476908debdb55f639875c35a24ecc4c54de1d24610b0389eaa4cf481df13e8e4a71267d2d5177e2fe3da7dc3429b6c1ab9f9e2662c60281bfeeaf7e3f98e267bdebf5fd4f2d949c4301fa31f17078c3049239c571352becfe67fe74453c3d331621a08d720b55e2645773af83471bd9850f6d32f1338a8c73f1fa6b9995036d6679dc47e5c45e3dca60c1b26744ebcc67abab1dc0fce722d98a0768238aa14aa16130c2f181d3dc73424f018a6b65dee097e44a7"
        });
    }
}
