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
import {Handler} from "./Handler.t.sol";

contract Invariant is StdInvariant, Test {
    Handler handler;

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

        handler = new Handler(hsfc, usdc, weth, yeildERC20, USER);

        //Create bytes array of our function signatures to target in the handler
        bytes4[] memory functionSignatures = new bytes4[](6);
        functionSignatures[0] = handler.depositUSDC.selector;
        functionSignatures[1] = handler.depositWETH.selector;
        functionSignatures[2] = handler.depositYeildERC20.selector;
        functionSignatures[3] = handler.withdrawUSDC.selector;
        functionSignatures[4] = handler.withdrawWETH.selector;
        functionSignatures[5] = handler.withdrawYeildERC20.selector;

        //FuzzSelector Object allows us to explicity tell our Foundry fuzzer what functions to target inside the specified target contract
        targetSelector(FuzzSelector({addr: address(handler), selectors: functionSignatures}));
        targetContract(address(handler));
    }

    function test_startingAmountExpected() public view {
        assert(startingUSDC == usdc.balanceOf(USER));
        assert(startingWETH == weth.balanceOf(USER));
    }

    function invariant_testInvariantBreaksWithHandler() public {
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

        /**
         * FOUND A WAY TO BREAK THE INVARIANT DUE TO YEILDERC20 TAKING A FEE FOR EVERY 10TH TRANSACTION CARRIED OUT AND SENT TO THE OWNER OF THE yeildERC20 CONTRACT
         *
         *
         *
         *       [26529] Invariant::invariant_testInvariantBreaksWithHandler()
         * ├─ [0] VM::startPrank(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D])
         * │   └─ ← ()
         * ├─ [14304] HandlerStatefulFuzzCatches::withdrawToken(YeildERC20: [0x56FF47Ae663554c91F7B4f40cc098E2Bf4243f39])
         * │   ├─ [3002] YeildERC20::transfer(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D], 1000000000000000000000000 [1e24])
         * │   │   └─ ← ERC20InsufficientBalance(0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, 999999999999999999999999 [9.999e23], 1000000000000000000000000 [1e24])
         * │   └─ ← ERC20InsufficientBalance(0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, 999999999999999999999999 [9.999e23], 1000000000000000000000000 [1e24])
         * └─ ← ERC20InsufficientBalance(0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, 999999999999999999999999 [9.999e23], 1000000000000000000000000 [1e24])
         */
    }
}
