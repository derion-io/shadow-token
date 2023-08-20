// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@derivable/erc1155-maturity/contracts/token/ERC1155/ERC1155Maturity.sol";

import "./Shadow.sol";
import "./interfaces/IShadowFactory.sol";
import "./MetaProxy.sol";

contract ShadowFactory is IShadowFactory, ERC1155Maturity {
    address immutable internal CODE;

    modifier onlyShadow(uint256 id) {
        address shadowToken = computeShadowAddress(id);
        require(msg.sender == shadowToken, "Shadow: UNAUTHORIZED");
        _;
    }

    constructor(string memory uri) ERC1155Maturity(uri) {
        CODE = address(new Shadow{salt: 0}(address(this)));
    }

    function deployShadow(uint256 id) external returns (address shadowToken) {
        shadowToken = MetaProxy.deploy(CODE, id);
        require(shadowToken != address(0), "ShadowFactory: Failed on deploy");
    }

    function computeShadowAddress(uint256 id) public view override returns (address pool) {
        bytes32 bytecodeHash = MetaProxy.computeBytecodeHash(CODE, id);
        return Create2.computeAddress(0, bytecodeHash, address(this));
    }

    function getShadowName(uint256) public view virtual returns (string memory) {
        return "Derivable Shadow Token";
    }

    function getShadowSymbol(uint256) public view virtual returns (string memory) {
        return "DST";
    }

    function getShadowDecimals(uint256) public view virtual returns (uint8) {
        return 18;
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
