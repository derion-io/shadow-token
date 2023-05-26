// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IShadowFactory {
    function deployingID() external view returns (uint);
    function computeShadowAddress(uint id) external view returns (address);
    function getShadowName(uint id) external view returns (string memory);
    function getShadowSymbol(uint id) external view returns (string memory);
    function getShadowDecimals(uint id) external view returns (uint8);
    function setApprovalForAllByShadow(uint id, address owner, address operator, bool approved) external;
    function safeTransferFromByShadow(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) external;
}
