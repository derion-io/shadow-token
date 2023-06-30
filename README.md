# Shadow Token

Shadow Token is an extension of [ERC-1155](https://eips.ethereum.org/EIPS/eip-1155) that allows any of its IDs to deploy a Shadow [ERC-20](https://eips.ethereum.org/EIPS/eip-20) token with its contract address for DeFi composability. Each Shadow contract can be deployed by anyone, anytime, and it shares the same balance and transfer behavior with the original token ID after being deployed.

## Transfer

The token can be transferred by both its ERC-1155 and its Shadow contract, which have the same effect.

## Allowance

Addresses with `ERC-1155.isApprovedForAll` allowance will have the maximum allowance for all its Shadow ERC-20 tokens.

Addresses with Shadow ERC-20 allowance do not have any additional allowance to other Shadow tokens or ERC-1155 IDs.

## Events

A Shadow transfer emits both ERC-20 and ERC-1155 events, but an ERC-1155 transfer does not emit any ERC-20 event, even after its Shadow is deployed.

## TokenReceiver

Contracts receiving tokens with ERC-1155 transfers need to implement `ERC1155TokenReceiver`. However, receiving tokens with Shadow transfer does not require any receiver interface.

## MetaProxy

[ERC-3448](https://eips.ethereum.org/EIPS/eip-3448): MetaProxy Standard is used for Shadow deployment. The target Shadow logic code is deployed in the ERC-1155 (Factory) constructor and resides at a different address.
