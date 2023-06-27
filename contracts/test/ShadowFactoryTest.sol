// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ShadowFactory.sol";

contract ShadowFactoryMintable is ShadowFactory {
    constructor() ShadowFactory("") {}

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external {
        super._mint(to, id, amount, block.timestamp, data);
    }
}
