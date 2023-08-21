// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../interfaces/IShadowFactory.sol";

contract FakeShadow {
    address public immutable ORIGIN;
    uint256 public immutable ID;

    constructor(address origin, uint256 id) {
        ORIGIN = origin;
        ID = id;
    }

    function transferFrom(address from, address to, uint256 amount) public {
        IShadowFactory(ORIGIN).safeTransferFromByShadow(from, to, ID, amount);
    }
}
