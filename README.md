Alchemix WstETH Adapter Critical Vulnerability Proof
This repository contains a comprehensive analysis and proof of concept for a critical vulnerability in Alchemix's WstETH adapter that completely bypasses slippage protection, allowing attackers to steal up to ~33% of users' funds during withdrawal operations through price manipulation attacks.

## Summary of the Vulnerability
The vulnerability exists because:

1-AlchemistV2._withdraw() performs slippage protection checks but then passes hardcoded 0 as minAmountOut to adapter.unwrap()
2-WstETHAdapter.unwrap() ignores its second parameter (slippage) and passes another hardcoded 0 to _exchange()
3-This creates a window for sandwich attacks between price check and execution
4-Despite users setting e.g. 5% slippage protection, they can lose up to ~33% of their funds

## Real-World PoC Files (3 files)


1. AlchemixRealAttackPoC.sol
Complete end-to-end attack simulation showing how a real user would be affected.

Key findings:

Demonstrates full sandwich attack scenario
Shows how user setting 5% slippage loses 33% of funds
Details exact attack execution flow and vulnerability points
Run with:
forge test --match-path test/AlchemixRealAttackPoC.sol -vvv --fork-url YOUR_RPC_ENDPOINT

Impact: Shows exactly how an attacker would execute a real-world attack on Alchemix users.

Ethical note: For ethical reasons, this test does not execute actual attacks on real user wallets.


2. AlchemixRealUserVulnerability.sol
Simulates the vulnerability's impact on user funds with calculations based on real contract behavior.

Key findings:

Traces actual function call path with vulnerability points
Demonstrates that user slippage setting is completely ignored
Calculates exact loss percentages
Run with:
forge test --match-path test/AlchemixRealUserVulnerability.sol -vvv --fork-url YOUR_RPC_ENDPOINT

Impact: Provides a precise analysis of how the vulnerability affects real users.

Ethical note: This test uses computational simulation instead of actually manipulating real user funds.


3. AlchemixAttackProof.sol
Validates the vulnerability through on-chain testing with forked mainnet.

Key findings:

Tests with actual forked mainnet conditions
Demonstrates bypassing of slippage protection mechanism
Shows real-world impact through on-chain interactions
Run with:
forge test --match-path test/AlchemixAttackProof.sol -vvv --fork-url YOUR_RPC_ENDPOINT

Ethical note: For ethical reasons, this test does not perform actual attacks on real user funds and demonstrates the vulnerability through safe simulations.

## Theoretical Vulnerability Analysis Files (4 files)

1. AttackSimulation.sol
Simple mathematical simulation of the attack.

Key findings:

Precise computational demonstration of user loss
Simulation of sandwich attack parameters
Shows difference between set slippage and actual loss
Run with:
forge test --match-path test/AttackSimulation.sol -vvv

2. CodeExcerptAnalysis.sol
Detailed analysis of the vulnerable code with exact line references.

Key findings:

Precise display of vulnerable source code sections
Root cause analysis of the vulnerability
Exact code points where vulnerability occurs
Run with:
forge test --match-path test/CodeExcerptAnalysis.sol -vvv

3. CodeVulnerabilityAnalysis.sol
Focused analysis of the specific vulnerability.

Key findings:

Technical explanation of the vulnerability
Detailed attack scenario
GitHub code references for validation
Run with:
forge test --match-path test/CodeVulnerabilityAnalysis.sol -vvv

4. ComprehensiveVulnerabilityAnalysis.sol
Complete vulnerability report with explanation and remediation recommendations.

Key findings:

Executive summary of the vulnerability
Impact and scope analysis
Vulnerable contract flow
Precise remediation recommendations
Run with:
forge test --match-path test/ComprehensiveVulnerabilityAnalysis.sol -vvv

Real-world Impact
This vulnerability puts all users withdrawing wstETH from Alchemix at risk. Due to the nature of DeFi sandwich attacks, users can lose approximately 33% of their withdrawn funds while believing they are protected by their slippage settings.

## Root Cause
The root cause is found in two specific code locations:

1- In AlchemistV2._withdraw() (Line ~1038):
```
unwrapped = adapter.unwrap(shares, 0);  // <-- VULNERABILITY: hardcoded 0
```

2- In WstETHAdapter.unwrap() (Line ~115):
```
function unwrap(uint256 amount, uint256) external returns (uint256) {
   // Second parameter is unnamed and ignored
   uint256 amountStETH = _exchange(amount, 0);  // <-- VULNERABILITY: hardcoded 0 again
}
```

## Recommended Fix
1-Pass the actual minAmountOut parameter throughout the call chain:

-In AlchemistV2._withdraw(): unwrapped = adapter.unwrap(shares, minAmountOut);
-In WstETHAdapter.unwrap(): uint256 amountStETH = _exchange(amount, minAmountOut);

2-Alternative fix: Perform atomic price check and execution

-Calculate price and execute exchange in a single operation
-Eliminate the window for price manipulation

## Ethical Considerations
While this repository contains code that could be used to exploit the vulnerability, I have chosen not to perform actual attacks against real users for ethical reasons. The tests operate on simulations and forked networks to prove the vulnerability without causing real damage.
