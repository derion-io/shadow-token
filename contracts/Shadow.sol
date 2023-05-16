// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "./interfaces/IERC1155Supply.sol";
import "./interfaces/IShadowFactory.sol";

contract Shadow is IERC20, IERC20Metadata {
    address public immutable ORIGIN;
    uint public immutable ID;

    constructor() {
        ORIGIN = msg.sender;
        ID = IShadowFactory(msg.sender).deployingID();
    }

    function name() public view virtual override returns (string memory) {
        return IShadowFactory(ORIGIN).getShadowName(ID);
    }

    function symbol() public view virtual override returns (string memory) {
        return IShadowFactory(ORIGIN).getShadowSymbol(ID);
    }

    function decimals() public view virtual override returns (uint8) {
        return IShadowFactory(ORIGIN).getShadowDecimals(ID);
    }

    function totalSupply() public view override returns (uint256) {
        return IERC1155Supply(ORIGIN).totalSupply(ID);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return IERC1155(ORIGIN).balanceOf(account, ID);
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        if (IERC1155(ORIGIN).isApprovedForAll(owner, spender)) {
            return type(uint256).max;
        }
        return 0;
    }

    function approve(address spender, uint amount) public virtual override returns (bool) {
        IShadowFactory(ORIGIN).setApprovalForAllByShadow(ID, msg.sender, spender, amount > 0);
        emit Approval(msg.sender, spender, amount > 0 ? type(uint256).max : 0);
        return true;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        IShadowFactory(ORIGIN).safeTransferFromByShadow(msg.sender, msg.sender, to, ID, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        IShadowFactory(ORIGIN).safeTransferFromByShadow(msg.sender, from, to, ID, amount);
        emit Transfer(from, to, amount);
        return true;
    }
}
