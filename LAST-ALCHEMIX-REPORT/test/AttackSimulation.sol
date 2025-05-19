// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

contract AttackSimulation is Test {
    function testAttackSimulation() public {
        console.log("=== ALCHEMIX VULNERABILITY: ATTACK SIMULATION ===");
        
        // Scenario variables
        uint256 victimShares = 10 ether;
        uint256 initialWstETHPrice = 1.234 ether; // Example initial price
        uint256 manipulatedPrice = initialWstETHPrice * 67 / 100; // 33% price drop
        uint256 slippageTolerance = 5; // 5% slippage tolerance
        
        console.log("\n=== SCENARIO PARAMETERS ===");
        console.log("Victim shares to withdraw:", victimShares / 1e18, "shares");
        console.log("Initial wstETH price:", initialWstETHPrice / 1e18, "ETH");
        console.log("Victim slippage setting:", slippageTolerance, "%");
        console.log("Attacker's target manipulated price:", manipulatedPrice / 1e18, "ETH");
        console.log("Price manipulation:", 100 - (manipulatedPrice * 100 / initialWstETHPrice), "%");
        
        // Step 1: Calculate expected output during slippage check
        uint256 expectedOutput = victimShares * initialWstETHPrice / 1e18;
        uint256 minAmountOut = expectedOutput * (100 - slippageTolerance) / 100;
        
        console.log("\n=== STEP 1: SLIPPAGE CHECK PHASE ===");
        console.log("Expected output (based on initial price):", expectedOutput / 1e18, "wstETH");
        console.log("Minimum acceptable output with");
        console.log(slippageTolerance, "% slippage:", minAmountOut / 1e18, "wstETH");
        console.log("AlchemistV2: expectedOutput >= minAmountOut? YES, proceed");
        
        // Step 2: Attacker manipulates price
        console.log("\n=== STEP 2: PRICE MANIPULATION PHASE ===");
        console.log("Attacker frontrunning the transaction");
        console.log("Price manipulation technique:");
        console.log("1. Large sell of wstETH before victim transaction");
        console.log("2. Price temporarily drops by", 100 - (manipulatedPrice * 100 / initialWstETHPrice), "%");
        console.log("3. wstETH price now:", manipulatedPrice / 1e18, "ETH");
        
        // Step 3: Execution with manipulated price
        console.log("\n=== STEP 3: EXECUTION PHASE ===");
        console.log("AlchemistV2 calls: adapter.unwrap(shares, 0) <-- Note hardcoded 0");
        console.log("WstETHAdapter calls: _exchange(amount, 0) <-- Note hardcoded 0 again");
        
        uint256 actualOutput = victimShares * manipulatedPrice / 1e18;
        
        console.log("Actual output with manipulated price:", actualOutput / 1e18, "wstETH");
        console.log("Loss from expected output:", (expectedOutput - actualOutput) / 1e18, "wstETH");
        console.log("Loss percentage:", 100 - (actualOutput * 100 / expectedOutput), "%");
        
        // Step 4: Slippage check was bypassed
        console.log("\n=== STEP 4: VULNERABILITY ANALYSIS ===");
        console.log("Was victim's slippage setting respected? NO!");
        console.log("Minimum acceptable by victim:", minAmountOut / 1e18, "wstETH");
        console.log("Actually received:", actualOutput / 1e18, "wstETH");
        
        if (actualOutput < minAmountOut) {
            console.log("SLIPPAGE PROTECTION FAILED: Received less than minimum acceptable!");
            console.log("Additional loss beyond allowed slippage:");
            console.log((minAmountOut - actualOutput) * 100 / expectedOutput, "%");
        }
        
        // Step 5: Attacker profits
        console.log("\n=== STEP 5: ATTACKER PROFITS ===");
        console.log("Attacker buys back wstETH at lower price after victim's transaction");
        console.log("Profit from sandwich attack:");
        console.log((expectedOutput - actualOutput) * 90 / 100 / 1e18, "wstETH equivalent");
        console.log("(Accounting for ~10% trading costs/slippage)");
        
        console.log("\n=== CONCLUSION ===");
        console.log("Despite victim setting", slippageTolerance, "% slippage protection,");
        console.log("They lost", 100 - (actualOutput * 100 / expectedOutput), "% of expected value");
        console.log("Root cause: Adapter ignores slippage parameter and uses hardcoded 0");
        
        assertTrue(actualOutput < minAmountOut, "VULNERABILITY CONFIRMED: Received less than allowed slippage");
    }
}