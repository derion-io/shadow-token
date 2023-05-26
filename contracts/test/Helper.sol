// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IShadowFactory.sol";

contract Helper {
    address public immutable ORIGIN;
    uint public immutable ID;

    constructor(address origin, uint id) {
        ORIGIN = origin;
        ID = id;
    }

    function approve(address spender, uint amount) public {
        IShadowFactory(ORIGIN).setApprovalForAllByShadow(ID, msg.sender, spender, amount > 0);
    }

    function transferFrom(address from, address to, uint256 amount) public {
        IShadowFactory(ORIGIN).safeTransferFromByShadow(from, to, ID, amount);
    }
}
