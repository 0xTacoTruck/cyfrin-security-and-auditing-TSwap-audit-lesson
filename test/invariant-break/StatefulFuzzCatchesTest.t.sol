// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {StatefulFuzzCatches} from "../../src/invariant-break/StatefulFuzzCatches.sol";

contract StatefulFuzzCatchesTest is StdInvariant, Test {
    StatefulFuzzCatches public sfc;

    function setUp() public {
        sfc = new StatefulFuzzCatches();
    }

    function test_DoMoreMathAgain(uint128 randomNumber) public {
        assert(sfc.doMoreMathAgain(randomNumber) != 0);
    }

    function invariant_CatchesBugStateful() public {
        //If myValue is changed to 0, then it will be possible for the `doMoreMathAgain` function to change the value of storedValue prior to returning 0 in the function - breaking the invariant
        assert(sfc.storedValue() != 0);
    }
}
