// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC1155Supply.sol";

interface IShadowFactory is IERC1155Supply {
    function deployShadow(uint id) external returns (address shadowToken);
    function computeShadowAddress(uint id) external view returns (address);
    function getShadowName(uint id) external view returns (string memory);
    function getShadowSymbol(uint id) external view returns (string memory);
    function getShadowDecimals(uint id) external view returns (uint8);
    function safeTransferFromByShadow(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) external;
}
