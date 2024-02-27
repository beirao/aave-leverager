// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/createx/src/CreateX.sol";
import "forge-std/console.sol";


contract Constants {
    /// all chain
    CreateX public constant createx = CreateX(address(0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)); // all chain

    address public immutable addressesProvider;
    address public immutable weth;

    constructor() {

        // Ethereum mainnet
        if (block.chainid == 1) {
            addressesProvider = address(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5);
            weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // weth
        }

        // Polygone
        else if (block.chainid == 137) {
            addressesProvider = address(0xd05e3E715d945B59290df0ae8eF85c1BdB684744);
            weth = address(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270); // wmatic
        }
    }

}