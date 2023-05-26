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

    mapping(address => mapping(address => uint256)) private _allowances;

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
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        IShadowFactory(ORIGIN).safeTransferFromByShadow(msg.sender, to, ID, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        IShadowFactory(ORIGIN).safeTransferFromByShadow(from, to, ID, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, allowance(msg.sender, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        if (IERC1155(ORIGIN).isApprovedForAll(msg.sender, spender)) {
            return true;
        }
        uint256 currentAllowance = allowance(msg.sender, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        if (IERC1155(ORIGIN).isApprovedForAll(owner, spender)) {
            return;
        }
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}
