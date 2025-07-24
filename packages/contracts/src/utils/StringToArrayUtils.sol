// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Bytes} from "@openzeppelin/contracts/utils/Bytes.sol";

library StringToArrayUtils {
    bytes1 private constant PIPE = bytes1("|");
    string private constant REVERT_REASON = "Invalid kid|iss|azp strings";

    /// @notice Converts a string containing three parts separated by '|' into an array of strings
    /// @param _strings The input string to be split
    /// @return An array of three strings, representing kid, iss, and azp
    /// @dev This function is used to parse the domainName parameter in other functions
    /// @dev Requires the input string to contain exactly two '|' characters
    function stringToArray(string memory _strings) internal pure returns (string[] memory) {
        bytes memory data = bytes(_strings);
        string[] memory parts = new string[](3);
        
        uint256 start; // 0
        uint256 end; // 0
        
        for (uint256 i; i < 3; i++) {
            if (i == 2) {
                end = data.length;
                require(start == Bytes.lastIndexOf(data, PIPE) + 1, REVERT_REASON);
            } else {
                end = Bytes.indexOf(data, PIPE, start);
                require(end < data.length, REVERT_REASON);
            }
            
            parts[i] = string(Bytes.slice(data, start, end));
            start = end + 1;
        }
        
        return parts;
    }
}
