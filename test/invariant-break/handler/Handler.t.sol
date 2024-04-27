// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {console} from "forge-std/console.sol";
import {HandlerStatefulFuzzCatches} from "../../../src/invariant-break/HandlerStatefulFuzzCatches.sol";
import {MockUSDC} from "../../mocks/MockUSDC.sol";
import {MockWETH} from "../../mocks/MockWETH.sol";
import {YeildERC20} from "../../mocks/YeildERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Handler is StdInvariant, Test {
    HandlerStatefulFuzzCatches hsfc;
    MockUSDC usdc;
    MockWETH weth;
    YeildERC20 yeildERC20;

    address user;

    constructor(
        HandlerStatefulFuzzCatches _handlerStatefulFuzzCatches,
        MockUSDC _mockUSDC,
        MockWETH _mockWETH,
        YeildERC20 _yeildERC20,
        address _user
    ) public {
        hsfc = _handlerStatefulFuzzCatches;
        usdc = _mockUSDC;
        weth = _mockWETH;
        yeildERC20 = _yeildERC20;
        user = _user;
    }

    function depositUSDC(uint256 _amount) public {
        //Bound the amount the deposit can be using Foundry cheatcode
        uint256 amount = bound(_amount, 0, usdc.balanceOf(user));
        vm.startPrank(user);
        //Approve the contract to transfer tokens on our behalf
        usdc.approve(address(hsfc), amount);
        hsfc.depositToken(usdc, amount);
        vm.stopPrank();
    }

    function depositWETH(uint256 _amount) public {
        //Bound the amount the deposit can be using Foundry cheatcode
        uint256 amount = bound(_amount, 0, weth.balanceOf(user));
        vm.startPrank(user);
        //Approve the contract to transfer tokens on our behalf
        weth.approve(address(hsfc), amount);
        hsfc.depositToken(weth, amount);
        vm.stopPrank();
    }

    function depositYeildERC20(uint256 _amount) public {
        //Bound the amount the deposit can be using Foundry cheatcode
        uint256 amount = bound(_amount, 0, yeildERC20.balanceOf(user));
        vm.startPrank(user);
        //Approve the contract to transfer tokens on our behalf
        yeildERC20.approve(address(hsfc), amount);
        hsfc.depositToken(yeildERC20, amount);
        vm.stopPrank();
    }

    function withdrawUSDC() public {
        vm.startPrank(user);
        hsfc.withdrawToken(usdc);
        vm.stopPrank();
    }

    function withdrawWETH() public {
        vm.startPrank(user);
        hsfc.withdrawToken(weth);
        vm.stopPrank();
    }

    function withdrawYeildERC20() public {
        vm.startPrank(user);
        hsfc.withdrawToken(yeildERC20);
        vm.stopPrank();
    }
}
