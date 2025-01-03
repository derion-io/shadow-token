// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../ShadowFactory.sol";

contract ShadowFactoryMintable is ShadowFactory {
    constructor() ShadowFactory("", "Derion Shadow Token", "DST") {}

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external {
        super._mint(to, id, amount, block.timestamp, data);
    }
}
