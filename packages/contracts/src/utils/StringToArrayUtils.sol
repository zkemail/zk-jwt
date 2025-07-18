// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Bytes} from "@openzeppelin/contracts/utils/Bytes.sol";

library StringToArrayUtils {
    /// @notice Converts a string containing three parts separated by '|' into an array of strings
    /// @param _strings The input string to be split
    /// @return An array of three strings, representing kid, iss, and azp
    /// @dev This function is used to parse the domainName parameter in other functions
    /// @dev Requires the input string to contain exactly two '|' characters
    function stringToArray(string memory _strings) internal pure returns (string[] memory) {
        bytes memory data = bytes(_strings);
        string[] memory parts = new string[](3);
        
        uint256 start = 0;
        for (uint256 i = 0; start < data.length; i++) {
            uint256 end = i == 2 ? data.length : Bytes.indexOf(data, bytes1("|"), start);
            require(i == 2 || end != type(uint256).max, "Invalid kid|iss|azp strings");
            parts[i] = string(Bytes.slice(data, start, end));
            start = end + 1;
        }
        
        return parts;
    }
}
