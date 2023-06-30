// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Create2.sol";

import "./ERC1155Supply.sol";
import "./Shadow.sol";
import "./interfaces/IShadowFactory.sol";


contract ShadowFactory is IShadowFactory, ERC1155Supply {
    bytes32 immutable public BYTECODE_HASH = keccak256(type(Shadow).creationCode);

    // transient storage
    uint public deployingID;

    constructor(string memory uri) ERC1155Supply(uri) {}

    function deployShadow(uint id) external returns (address shadowToken) {
        deployingID = id;
        shadowToken = Create2.deploy(0, bytes32(id), type(Shadow).creationCode);
        delete deployingID;
    }

    function computeShadowAddress(uint id) public view override returns (address pool) {
        return Create2.computeAddress(bytes32(id), BYTECODE_HASH, address(this));
    }

    function getShadowName(uint) public view virtual returns (string memory) {
        return "Derivable Shadow Token";
    }

    function getShadowSymbol(uint) public view virtual returns (string memory) {
        return "DST";
    }

    function getShadowDecimals(uint) public view virtual returns (uint8) {
        return 18;
    }

    modifier onlyShadow(uint id) {
        address shadowToken = computeShadowAddress(id);
        require(msg.sender == shadowToken, "Shadow: UNAUTHORIZED");
        _;
    }

    function safeTransferFromByShadow(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public virtual override onlyShadow(id) {
        return _safeTransferFrom(from, to, id, amount, "");
    }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal override virtual {
        address shadowToken = computeShadowAddress(id);
        if (msg.sender == shadowToken) {
            return; // skip the acceptance check
        }
        super._doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }
}
