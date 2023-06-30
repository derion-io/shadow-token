// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IShadowFactory.sol";

interface IShadowFactoryMintable is IShadowFactory {
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;
}
