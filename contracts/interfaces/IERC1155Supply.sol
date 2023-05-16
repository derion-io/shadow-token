// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC1155Supply {
    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) external view returns (uint256);
}
