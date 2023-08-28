// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./Token.sol";

contract ShadowFactoryMintable is Token {
    constructor() Token("") {}

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external {
        super._mint(to, id, amount, block.timestamp, data);
    }
}
