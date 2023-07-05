// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC1155/extensions/ERC1155Supply.sol)
// Derivable Contracts (ERC1155Supply.sol)

pragma solidity ^0.8.0;

import "@derivable/erc1155-maturity/contracts/token/ERC1155/ERC1155Maturity.sol";
import "./interfaces/IERC1155Supply.sol";

/**
 * @dev Extension of ERC1155 that adds tracking of total supply per id.
 *
 * Useful for scenarios where Fungible and Non-fungible tokens have to be
 * clearly identified. Note: While a totalSupply of 1 might mean the
 * corresponding is an NFT, there is no guarantees that no other token with the
 * same id are not going to be minted.
 */
contract ERC1155Supply is IERC1155Supply, ERC1155Maturity {
    mapping(uint256 => uint256) internal _totalSupply;

    constructor(string memory uri) ERC1155Maturity(uri) {}

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view override virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) public view override virtual returns (bool) {
        return totalSupply(id) > 0;
    }

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        uint256 locktime,
        bytes memory data
    ) internal override virtual {
        _totalSupply[id] += amount;
        super._mint(to, id, amount, locktime, data);
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        uint256 locktime,
        bytes memory data
    ) internal override virtual {
        for (uint256 i = 0; i < ids.length; ++i) {
            _totalSupply[ids[i]] += amounts[i];
        }
        super._batchMint(to, ids, amounts, locktime, data);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal override virtual {
        uint256 supply = _totalSupply[id];
        require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
        unchecked {
            _totalSupply[id] = supply - amount;
        }
        super._burn(from, id, amount);
    }

    function _batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal override virtual {
        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];
            uint256 supply = _totalSupply[id];
            require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
            unchecked {
                _totalSupply[id] = supply - amount;
            }
        }
        super._batchBurn(from, ids, amounts);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public virtual override(IERC1155, ERC1155Maturity) {
        if (from == address(0)) {
            _totalSupply[id] += amount;
        }

        if (to == address(0)) {
            uint256 supply = _totalSupply[id];
            require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
            unchecked {
                _totalSupply[id] = supply - amount;
            }
        }
        super.safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public virtual override(IERC1155, ERC1155Maturity) {
        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = _totalSupply[id];
                require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }
}
