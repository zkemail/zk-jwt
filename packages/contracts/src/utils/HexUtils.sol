// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

library HexUtils {
    function bytes32ToHexString(
        bytes32 _bytes32
    ) internal pure returns (string memory) {
        bytes memory hexChars = "0123456789abcdef";
        bytes memory str = new bytes(64);
        uint256 strIndex = 0;
        bool nonZeroFound = false;

        for (uint256 i = 0; i < 32; i++) {
            uint8 byteValue = uint8(_bytes32[i]);
            if (byteValue != 0 || nonZeroFound) {
                str[strIndex++] = hexChars[byteValue >> 4];
                str[strIndex++] = hexChars[byteValue & 0x0f];
                nonZeroFound = true;
            }
        }

        // If no non-zero byte was found, return "0"
        if (strIndex == 0) {
            return "0";
        }

        // Create a new bytes array with the correct length
        bytes memory trimmedStr = new bytes(strIndex);
        for (uint256 j = 0; j < strIndex; j++) {
            trimmedStr[j] = str[j];
        }

        return string(trimmedStr);
    }

    function hexStringToBytes32(
        string memory hexString
    ) internal pure returns (bytes32) {
        bytes memory hexBytes = bytes(hexString);
        require(hexBytes.length <= 64, "Invalid hex string length");

        bytes32 result;
        uint256 length = hexBytes.length / 2; // Calculate the number of bytes
        for (uint256 i = 0; i < hexBytes.length; i += 2) {
            result |=
                bytes32(
                    uint256(
                        (_charToByte(hexBytes[i]) << 4) |
                            _charToByte(hexBytes[i + 1])
                    )
                ) <<
                ((length - 1 - i / 2) * 8);
        }
        return result;
    }

    function _charToByte(bytes1 char) internal pure returns (uint8) {
        if (char >= 0x30 && char <= 0x39) {
            return uint8(char) - 0x30; // '0' - '9'
        } else if (char >= 0x61 && char <= 0x66) {
            return uint8(char) - 0x61 + 10; // 'a' - 'f'
        } else if (char >= 0x41 && char <= 0x46) {
            return uint8(char) - 0x41 + 10; // 'A' - 'F'
        }
        revert("Invalid hex character");
    }
}
