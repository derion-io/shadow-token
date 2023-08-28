// // SPDX-License-Identifier: MIT
pragma solidity 0.8.20;


import "../ShadowFactory.sol";
import "@derivable/erc1155-maturity/contracts/token/ERC1155/ERC1155Maturity.sol";

contract Token is ShadowFactory, ERC1155Maturity {
    constructor(string memory uri) ERC1155Maturity(uri) {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual override(ShadowFactory, ERC1155Maturity) {
        address shadowToken = computeShadowAddress(id);
        if (msg.sender == shadowToken) {
            return; // skip the acceptance check
        }
        ERC1155Maturity._doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual override(ShadowFactory, ERC1155Maturity) {
        ERC1155Maturity._safeTransferFrom(from, to, id, amount, data);
    }
}