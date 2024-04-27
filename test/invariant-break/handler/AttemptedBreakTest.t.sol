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

contract AttemptedBreakTest is StdInvariant, Test {
    HandlerStatefulFuzzCatches hsfc;
    MockUSDC usdc;
    MockWETH weth;
    YeildERC20 yeildERC20;

    IERC20[] supportedTokens;

    address public USER = makeAddr("user");
    uint256 startingUSDC;
    uint256 startingWETH;

    function setUp() public {
        vm.startPrank(USER);
        usdc = new MockUSDC();
        weth = new MockWETH();
        yeildERC20 = new YeildERC20();
        usdc.mint(USER, yeildERC20.INITIAL_SUPPLY());
        startingUSDC = usdc.balanceOf(USER);
        weth.mint(USER, yeildERC20.INITIAL_SUPPLY());
        startingWETH = weth.balanceOf(USER);
        vm.stopPrank();

        supportedTokens.push(usdc);
        supportedTokens.push(weth);
        supportedTokens.push(yeildERC20);

        hsfc = new HandlerStatefulFuzzCatches(supportedTokens);

        targetContract(address(hsfc));
    }

    function test_startingAmountExpected() public view {
        assert(startingUSDC == usdc.balanceOf(USER));
        assert(startingWETH == weth.balanceOf(USER));
    }

    function invariant_CanOnlywithdrawTotalBalance() public {
        vm.startPrank(USER);
        //Call withdraw
        hsfc.withdrawToken(yeildERC20);
        hsfc.withdrawToken(usdc);
        hsfc.withdrawToken(weth);

        assert(
            usdc.balanceOf(address(hsfc)) == 0 && weth.balanceOf(address(hsfc)) == 0
                && yeildERC20.balanceOf(address(hsfc)) == 0
        );

        assert(
            usdc.balanceOf(USER) == startingUSDC && weth.balanceOf(USER) == startingWETH
                && yeildERC20.balanceOf(USER) == yeildERC20.INITIAL_SUPPLY()
        );
    }
}
