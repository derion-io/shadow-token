// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IShadowFactory {
    function deployingID() external view returns (uint);
    function computeShadowAddress(uint id) external view returns (address);
    function getShadowMetadata(uint id, bytes32 key) external view returns (bytes32 data);
    function setApprovalForAllByShadow(uint id, address owner, address operator, bool approved) external;
    function safeTransferFromByShadow(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) external;
}
