// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Leverager} from "../src/Leverager.sol";
import "lib/createx/src/CreateX.sol";
import "forge-std/console.sol";
import "./Constants.sol";


contract LeveragerDeployer is Script, Constants {

    function setUp() public {}

    function run() public {
        vm.broadcast();
        bytes memory args = abi.encode(addressesProvider, weth);
        bytes memory cachedInitCode = abi.encodePacked(type(Leverager).creationCode, args);

        address l = createx.deployCreate3{value: 0}(bytes32("bytemasons"), cachedInitCode);

        console.log("Levrager address: ", l);
    }
}
