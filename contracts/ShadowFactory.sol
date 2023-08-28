// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/Create2.sol";

import "./Shadow.sol";
import "./interfaces/IShadowFactory.sol";
import "./MetaProxy.sol";

abstract contract ShadowFactory is IShadowFactory {
    address internal immutable CODE;

    modifier onlyShadow(uint256 id) {
        address shadowToken = computeShadowAddress(id);
        require(msg.sender == shadowToken, "Shadow: UNAUTHORIZED");
        _;
    }

    constructor() {
        CODE = address(new Shadow{salt: 0}(address(this)));
    }

    function deployShadow(uint256 id) external returns (address shadowToken) {
        shadowToken = MetaProxy.deploy(CODE, id);
        require(shadowToken != address(0), "ShadowFactory: Failed on deploy");
    }

    function safeTransferFromByShadow(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public virtual override onlyShadow(id) {
        return _safeTransferFrom(from, to, id, amount, "");
    }

    function computeShadowAddress(
        uint256 id
    ) public view override returns (address pool) {
        bytes32 bytecodeHash = MetaProxy.computeBytecodeHash(CODE, id);
        return Create2.computeAddress(0, bytecodeHash, address(this));
    }

    function getShadowName(
        uint256
    ) public view virtual returns (string memory) {
        return "Derivable Shadow Token";
    }

    function getShadowSymbol(
        uint256
    ) public view virtual returns (string memory) {
        return "DST";
    }

    function getShadowDecimals(uint256) public view virtual returns (uint8) {
        return 18;
    }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual;

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual;
}
