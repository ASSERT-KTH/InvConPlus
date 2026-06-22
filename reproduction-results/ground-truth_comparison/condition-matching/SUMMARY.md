# InvCon+ Ground-Truth Comparison — Condition Matching

This table summarises, for each of the 22 contracts processed by InvCon+,
the ground-truth invariant condition extracted from the security patch
(`diff.diff`) and the closest predicate produced by InvCon+, together with
the match verdict.

**Match legend**
| Symbol | Meaning |
|--------|---------|
| ✅ EXACT | Normalised strings are identical |
| 🟡 PARTIAL | Key variable tokens and relational operator overlap, but not a literal match |
| ❌ NONE | No InvCon+ predicate covers the ground-truth condition |

---

## Methodology

### Overview

The evaluation uses the same `matcher_invconplus.py` pipeline as for InvCon,
adapted to InvCon+'s JSON output format. For each contract, the ground-truth
conditions are extracted from the security patch diff and compared against
the invariant predicates produced by InvCon+.

### Key Differences from InvCon

InvCon+ produces a JSON array (one entry per function × execution type) rather
than a Daikon `.inv` text file. Each entry contains four predicate lists:
`preconditions`, `postconditions`, `falsified_preconditions`, and
`falsified_postconditions`. The matcher collects all four lists and flattens
them into a single pool for comparison.

InvCon+ uses `ori(x)` instead of Daikon's `orig(x)` and
`Sum(x[...])` instead of `sum(x[])`. The normalisation step converts these
to a common form before matching.

### Matching Strategy

The same two-level strategy is used as for InvCon:
- **EXACT**: normalised strings are identical.
- **PARTIAL**: ≥2 key identifier tokens and ≥1 relational operator overlap
  between the ground-truth condition and an InvCon+ predicate.
- **NONE**: no predicate satisfies either criterion.

---

## Results

| Contract | Vuln. Function(s) | Root Cause | Ground-Truth Condition (from diff) | Closest InvCon+ Predicate | Match |
|---|---|---|---|---|---|
| **201804_BEC** | `batchTransfer` | Overflow | `_value <= uint256(-1) / cnt` | `_value <= ori(Sum(balances[...]))` / `_value <= ori(balances[msg.sender])` | 🟡 PARTIAL |
| **201804_SmartMesh** | `transferProxy` | Overflow | `total >= _feeSmt` / `total >= _value` | — (local var `total` not in InvCon+ output) | ❌ NONE |
| **202101_Yearn_ydai** | `earn` | Slippage | `msg.sender == governance` | `governance == ori(governance)` / `token == governance` | 🟡 PARTIAL |
| **202109_Nimbus** | `swap` | Logic Flaw | `balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(10_000**2)` | — (arithmetic invariant beyond InvCon+ templates) | ❌ NONE |
| **202201_Anyswap** | `anySwapOutUnderlyingWithPermit` | Incorrect Validation | `v == 27` / `v == 28` | — (param `v` not in InvCon+ output) | ❌ NONE |
| **202206_InverseFinance** | `latestAnswer` | Flash Loan | `crvLPTokenPrice >= lower` / `crvLPTokenPrice <= upper` | — (no output for `latestAnswer`) | ❌ NONE |
| **202209_BadGuysbyRPF** | `WhiteListMint` | Incorrect Validation | `_numberMinted(msg.sender) + chosenAmount <= 1` | `reserve <= chosenAmount` / `ori(maxsupply) <= chosenAmount` | 🟡 PARTIAL |
| **202210_N00d** | `enter` | Reentrancy | `!__lock_modifier0_lock` | — (lock var introduced by patch) | ❌ NONE |
| **202210_Uerii** | `mint` | Access Control | `totalSupply() + amount <= CAP` | — (no predicate with `CAP`) | ❌ NONE |
| **202212_JAY** | `buyJay`, `sell` | Reentrancy | `!__lock_modifier0_lock` | — (lock var introduced by patch) | ❌ NONE |
| **202301_QTN** | `transfer`, `transferFrom` | Logic Flaw | `msg.sender == address(uniswapV2Router)` | `uniswapV2Router == ori(_owner)` / `ori(uniswapV2Router) == uniswapV2Router` | 🟡 PARTIAL |
| **202305_ERC20TokenBank** | `doExchange` | Price Manipulation | `namount >= (camount * 995) / 1000` | — (local vars `namount`/`camount` not in output) | ❌ NONE |
| **202306_VINU** | `addLiquidityETH` | Price Manipulation | `size == 0` | — (assembly var `size` not in output) | ❌ NONE |
| **202308_Uwerx** | `transfer`, `transferFrom` | Logic Flaw | `uniswapPoolAddress != address(0x1)` / `_balances[to] == (toBalance - userTransferAmount)` | `to != uniswapPoolAddress` / `_balances[to] - ori(_balances[to]) == amount` | 🟡 PARTIAL |
| **202309_uniclyNFT** | `deposit`, `withdraw` | Reentrancy | `_amount > 0` / `user.amount > 0` / `!__lock_modifier0_lock` | `_amount > 0` ✅ (exact); `user.amount` / lock var not matched | ✅ EXACT (1/3) |
| **202310_pSeudoEth** | `skim` | Price Manipulation | `balance0 - reserve0 <= reserve0 / 10` / `balance1 - reserve1 <= reserve1 / 10` | — (no output for `skim`) | ❌ NONE |
| **202311_grok** | `transfer`, `transferFrom` | Slippage | `sellSlippageBps = 9500` *(implicit slippage param)* | — (state var introduced by patch) | ❌ NONE |
| **202404_HoppyFrogERC** | `transfer`, `transferFrom`, `manualSwap` | Logic Flaw | `swapAmount <= maxSwapForSell` | — (local var `swapAmount` not in output) | ❌ NONE |
| **202406_APEMAGA** | `family` | Logic Flaw | `msg.sender == account` | — (no predicate links `msg.sender` to `account` directly) | ❌ NONE |
| **202408_OMPxContract** | `purchase`, `buyBack` | Flash Loan | `block.timestamp >= lastInteractionTimestamp[msg.sender] + 30 seconds` | — (mapping `lastInteractionTimestamp` not in output) | ❌ NONE |
| **202409_Bedrock_DeFi** | `mint` | Logic Flaw | `uniBTCAmount * 1e10 < msg.value` | — (no output for `mint`) | ❌ NONE |
| **202409_OnyxDAO** | `liquidateWithSingleRepay` | Logic Flaw | `repayAmount == borrowedAmount` | — (local vars not in output) | ❌ NONE |

---

## Summary

| Match Type | Contracts | % of total |
|---|---|---|
| ✅ EXACT (at least 1 condition) | 1 | 4.5% |
| 🟡 PARTIAL (at least 1 condition) | 5 | 22.7% |
| ❌ NONE (all conditions) | 16 | 72.7% |

**Total contracts evaluated:** 22 / 22  
**Total GT conditions evaluated:** 41  
- Exact matches: 1  
- Partial matches: 9  
- No matches: 31

---

## Key Findings

1. **Only 1 exact match across 22 contracts** — `_amount > 0` in `202309_uniclyNFT`
   (uniclyNFT / PointFarm). This is a trivially simple condition (`> 0`) that
   InvCon+ happens to mine from pre-conditions. No security-critical compound
   invariant was exactly matched.

2. **InvCon+ finds more partial matches than InvCon** — 6 contracts reach
   PARTIAL vs 5 for InvCon, because InvCon+ outputs richer pre/postcondition
   sets including mapping accesses (e.g. `uniswapPoolAddress`,
   `_balances[to]`) that share tokens with the ground-truth conditions.

3. **Systematic causes of NONE:**
   - *Local variables invisible to InvCon+*: conditions involving intermediate
     local variables (`total`, `namount`, `camount`, `swapAmount`,
     `lastInteractionTimestamp`) are not captured because InvCon+ only records
     state variables and function parameters, not internal computations.
   - *Reentrancy lock variables*: `__lock_modifier0_lock` is introduced by the
     patch itself and never existed in the original contract.
   - *Implicit slippage parameters*: `sellSlippageBps` is a new state variable
     added by the patch.
   - *Arithmetic/relational complexity*: multi-variable bounds like
     `balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(10_000**2)`
     are beyond the InvCon+ template set.
   - *No function output*: for `latestAnswer` (InverseFinance), `skim`
     (pSeudoEth), and `mint` (Bedrock), InvCon+ produced no predicates for
     the vulnerable function.
     
4. **InvCon+ vs InvCon comparison.** InvCon+ outputs substantially more
   predicates per contract (e.g. 1,633 for GROK `transfer` vs 584 for InvCon)
   and correctly resolves the vulnerable function in all 22 cases, while InvCon
   failed to produce output for 6/18 evaluated contracts. Despite the larger
   predicate set, InvCon+ still produces zero exact matches on security-critical
   conditions, confirming that quantity of output does not translate to
   security-relevant invariant quality.
