// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Leverager} from "../src/Leverager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/interfaces/IDebtTokenBase.sol";
import "../src/interfaces/ILendingPool.sol";
import "forge-std/console.sol";
import "lib/createx/src/CreateX.sol";

CreateX constant createx = CreateX(address(0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)); // all chain

address constant addressesProvider = address(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5); // mainnet
address constant weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // mainnet
address constant aweth = address(0x030bA81f1c18d280636F32af80b9AAd02Cf0854e); // mainnet
address constant wethDebtToken = address(0xF63B34710400CAd3e044cFfDcAb00a0f32E33eCf); // mainnet

contract LeveragerTest is Test {
    Leverager l;
    address alice = address(0xa11ce);
    uint initialMint = 111 ether;

    function setUp() public {
        address arg1 = addressesProvider;
        address arg2 = weth;
        bytes memory args = abi.encode(arg1, arg2);
        bytes memory cachedInitCode = abi.encodePacked(type(Leverager).creationCode, args);

        l = Leverager(payable(createx.deployCreate3{value: 0}(bytes32("bytemasons"), cachedInitCode)));
        deal({ token: weth, to: alice, give: initialMint });
        deal(alice, initialMint);
    }

    function test_leverageERC20(uint initialDeposit, uint borrowAmount) public {
        vm.assume(initialDeposit < initialMint);
        vm.assume(borrowAmount < initialDeposit);
        vm.assume(borrowAmount != 0);

        vm.startPrank(alice);
        IERC20(weth).approve(address(l), initialDeposit);
        IDebtTokenBase(wethDebtToken).approveDelegation(address(l), borrowAmount);
        l.leverageERC20(weth, initialDeposit, borrowAmount, 1.2e18);

        assertApproxEqAbs(IERC20(weth).balanceOf(alice), 111 ether - initialDeposit, 1);
        assertApproxEqAbs(IERC20(aweth).balanceOf(alice), initialDeposit + borrowAmount, 1);
        assertApproxEqAbs(IERC20(wethDebtToken).balanceOf(alice), borrowAmount, 1);

        assertEq(IERC20(weth).balanceOf(address(l)), 0, "4");
        assertEq(IERC20(aweth).balanceOf(address(l)), 0, "5");
        assertEq(IERC20(wethDebtToken).balanceOf(address(l)), 0, "6");
    }

    function test_deleverageERC20(uint initialDeposit, uint borrowAmount) public {
        test_leverageERC20(initialDeposit, borrowAmount);    

        vm.startPrank(alice);

        IERC20(aweth).approve(address(l), type(uint256).max);
        l.deleverageERC20(weth);

        assertApproxEqAbs(IERC20(weth).balanceOf(alice), 111 ether, 0.01 ether);
        assertEq(IERC20(aweth).balanceOf(alice), 0);
        assertEq(IERC20(wethDebtToken).balanceOf(alice), 0);

        assertEq(IERC20(weth).balanceOf(address(l)), 0, "4");
        assertEq(IERC20(aweth).balanceOf(address(l)), 0, "5");
        assertEq(IERC20(wethDebtToken).balanceOf(address(l)), 0, "6");
    }

    function test_leverageNative(uint initialDeposit, uint borrowAmount) public {
        vm.assume(initialDeposit < initialMint);
        vm.assume(borrowAmount < initialDeposit);
        vm.assume(borrowAmount != 0);

        vm.startPrank(alice);
        IDebtTokenBase(wethDebtToken).approveDelegation(address(l), borrowAmount);
        l.leverageNative{value: initialDeposit}(borrowAmount, 1.2e18);

        assertApproxEqAbs(alice.balance, 111 ether - initialDeposit, 1, "1");
        assertApproxEqAbs(IERC20(aweth).balanceOf(alice), initialDeposit + borrowAmount, 1, "2");
        assertApproxEqAbs(IERC20(wethDebtToken).balanceOf(alice), borrowAmount, 1, "3");

        assertEq(IERC20(weth).balanceOf(address(l)), 0, "4");
        assertEq(IERC20(aweth).balanceOf(address(l)), 0, "5");
        assertEq(IERC20(wethDebtToken).balanceOf(address(l)), 0, "6");
    }

    function test_deleverageNative(uint initialDeposit, uint borrowAmount) public {
        test_leverageNative(initialDeposit, borrowAmount);

        vm.startPrank(alice);
        IERC20(aweth).approve(address(l), type(uint256).max);
        l.deleverageNative();

        assertApproxEqAbs(alice.balance, 111 ether, 0.01 ether, "1");
        assertEq(IERC20(aweth).balanceOf(alice), 0, "2");
        assertEq(IERC20(wethDebtToken).balanceOf(alice), 0, "3");

        assertEq(IERC20(weth).balanceOf(address(l)), 0, "4");
        assertEq(IERC20(aweth).balanceOf(address(l)), 0, "5");
        assertEq(IERC20(wethDebtToken).balanceOf(address(l)), 0, "6");
    }

    // function invariant_LeverageContractBalanceMustRemainZero() 
}