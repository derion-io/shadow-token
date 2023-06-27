// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@derivable/erc1155-maturity/contracts/token/ERC1155/IERC1155Maturity.sol";

interface IERC1155Supply is IERC1155Maturity {
    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) external view returns (uint256);

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) external view returns (bool);
}
