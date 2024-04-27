// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Test} from "forge-std/Test.sol";

import {StatelessFuzzCatches} from "../../src/invariant-break/StatelessFuzzCatches.sol";

contract StatelessFuzzCatchesTest is StdInvariant, Test {
    StatelessFuzzCatches public sfc;

    function setUp() public {
        sfc = new StatelessFuzzCatches();

        //Set target contract for stateful fuzzing
        targetContract(address(sfc));
    }

    function testFuzzCatchesBugStateless(uint128 randomNumber) public {
        //Invariant is that it should never return a value of zero
        assert(sfc.doMath(randomNumber) != 0);
    }
}
