# InvCon+ ↔ Ground Truth comparison via Sindi

Pipeline to compare the invariants produced by **InvCon+** (in JSON format)
against the **ground truth** extracted from the patches (`diff.diff`), using
the semantic differencing engine **Sindi**.

This is the InvCon+ counterpart of the InvCon pipeline (see `README.md`). The
semantic comparison is delegated **100% to Sindi** (`Comparator().compare`);
the only additional work is translating InvCon+'s JSON dialect into
Sindi-compatible predicates.

---

## Components

| File | Role |
|------|------|
| `extract_gt_from_diffs.py` | Extracts the ground truth from the `diff.diff` files → `ground_truth.csv` (shared with the InvCon pipeline) |
| `invconplus_preprocessor.py` | Translates InvCon+'s JSON invariants into Sindi-compatible predicates |
| `compare_invconplus_sindi.py` | Compares each InvCon+ invariant against the ground truth via Sindi → CSV |
| `test_invconplus_preprocessor.py` | Tests for the preprocessor's translation rules |

The ground truth is the **same** as the InvCon pipeline: both tools are
evaluated against identical patch-derived predicates.

---

## Requirements

- Python 3.8+
- Sindi installed:

```bash
pip install Sindi --break-system-packages
```

---

## Execution (two steps)

### Step 1 — Extract the ground truth from the diffs

```bash
python3 extract_gt_from_diffs.py --diffs-dir ./diffs --out ./ground_truth.csv
```

(Identical to the InvCon pipeline; if you already produced `ground_truth.csv`
there, reuse it.)

### Step 2 — Compare with Sindi

```bash
python3 compare_invconplus_sindi.py \\
    --json-dir ./json \\
    --ground-truth ./ground_truth.csv \\
    --out ./verdicts_plus.csv
```

For each contract it looks for the JSON in `json/<contract>/*.inv.json`,
translates each invariant with `invconplus_preprocessor`, and compares it
against the ground-truth predicate through Sindi.

The ground truth is compared against **both** `preconditions` and
`postconditions` of every program point (they are merged before comparison).

Produces two files:

- `verdicts_plus.csv` — one row per compared InvCon+ invariant (detail)
- `verdicts_plus_summary.csv` — one verdict per `(contract, function)` pair

---

## Output: `verdicts_plus_summary.csv`

One row per `(contract, function)` pair with Sindi's textual verdict.

| Column | Meaning |
|--------|---------|
| `contract` | Contract name |
| `function` | Function the ground truth refers to |
| `gt_predicate` | The ground-truth predicate extracted from the diff |
| `n_invariant_lines` | Number of InvCon+ invariants examined for the vulnerable function |
| `verdict_raw` | Verdict (see below) |

Possible values of `verdict_raw`:

Sindi's four official strings (when a comparison actually took place):

- `The predicates are equivalent.`
- `The first predicate is stronger.` — the InvCon+ invariant is stronger
- `The second predicate is stronger.` — the ground truth is stronger
- `The predicates are not equivalent and neither is stronger.`

Plus two pipeline labels (when no Sindi comparison was possible):

- `no invariant for the vulnerable function` — InvCon+ produced empty
  `preconditions`/`postconditions` for that function (`n_invariant_lines = 0`),
  so there is nothing to compare against the ground truth.
- `no comparable invariant (all non-relational)` — InvCon+ produced invariants,
  but all of them are non-relational (`Sum(...)` aggregates or `one of [...]`
  enumerations), none of which is a boolean predicate Sindi can compare.

Note: the **first** predicate is the InvCon+ invariant, the **second** is the
ground truth.

---

## The InvCon+ preprocessor

InvCon+ produces invariants as JSON with a syntax that differs from InvCon's plain
Daikon dialect. `invconplus_preprocessor.py` handles:

- `ori(x)` — left as-is (Sindi symbolises it, like `orig(x)`)
- `Sum(balances[...])` — aggregate over a mapping. Marked **`unmappable`** and
  skipped, by design: the ground truth never uses `Sum(...)` aggregates, so
  mapping them to an opaque symbol would only ever yield `none`. Marking them
  `unmappable` keeps the distinction between "aggregate with no counterpart in
  the GT" and a real negative comparison, and avoids crashing Sindi's tokenizer.
- `one of [...]` — Daikon value enumeration, a meta-statement → `meta`, skipped
- indexed accesses like `balances[msg.sender]` — left untouched


### Preprocessor tests

```bash
python3 test_invconplus_preprocessor.py
```

Expected:

```
[PASS] classification_and_mapping
[PASS] relational_outputs_parse_in_sindi
2/2 tests passed.
```

---

## Results

Comparison outcome for the evaluated contracts (28 ground-truth predicates
across the dataset). Each verdict is the strongest one obtained by Sindi across
all InvCon+ invariants (pre- and post-conditions) for that
`(contract, function)`, or a pipeline label when no comparison was possible.

| Contract | Function | Ground-truth predicate | Verdict (Sindi) |
|---|---|---|---|
| 201804_BEC | batchTransfer | `_value <= uint256(-1) / cnt` | The predicates are not equivalent and neither is stronger. |
| 201804_SmartMesh | transferProxy | `total >= _feeSmt` | no invariant for the vulnerable function |
| 201804_SmartMesh | transferProxy | `total >= _value` | no invariant for the vulnerable function |
| 202102_Yearn_ydai | earn | `msg.sender == governance` | The predicates are not equivalent and neither is stronger. |
| 202109_Nimbus | swap | `balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(10_000**2)` | no comparable invariant (all non-relational) |
| 202201_Anyswap | anySwapOutUnderlyingWithPermit | `v == 27 \|\| v == 28` | no invariant for the vulnerable function |
| 202206_InverseFinance | latestAnswer | `crvLPTokenPrice >= lower` | no invariant for the vulnerable function |
| 202206_InverseFinance | latestAnswer | `crvLPTokenPrice <= upper` | no invariant for the vulnerable function |
| 202209_BadGuysbyRPF | WhiteListMint | `_numberMinted(msg.sender) + chosenAmount <= 1` | The predicates are not equivalent and neither is stronger. |
| 202210_N00d | enter | `!__lock_modifier0_lock` | The predicates are not equivalent and neither is stronger. |
| 202210_Uerii | mint | `totalSupply() + amount <= CAP` | The predicates are not equivalent and neither is stronger. |
| 202212_JAY | buyJay | `!__lock_modifier0_lock` | The predicates are not equivalent and neither is stronger. |
| 202301_QTN | transfer | `msg.sender == address(uniswapV2Router)` | The predicates are not equivalent and neither is stronger. |
| 202305_ERC20TokenBank | doExchange | `namount >= (camount * 995) / 1000` | The predicates are not equivalent and neither is stronger. |
| 202306_VINU | addLiquidityETH | `size == 0` | no invariant for the vulnerable function |
| 202308_Uwerx | transfer | `uniswapPoolAddress!=address(0x1)` | The predicates are not equivalent and neither is stronger. |
| 202308_Uwerx | transfer | `_balances[to]==(toBalance - userTransferAmount)` | The predicates are not equivalent and neither is stronger. |
| 202309_JumpFarm | unstake | `TOKEN.balanceOf(address(this)) <= balanceBefore` | The predicates are not equivalent and neither is stronger. |
| 202309_uniclyNFT | withdraw | `!__lock_modifier0_lock` | The predicates are not equivalent and neither is stronger. |
| 202310_pSeudoEth | skim | `balance0 - reserve0 <= reserve0 / 10` | no invariant for the vulnerable function |
| 202310_pSeudoEth | skim | `balance1 - reserve1 <= reserve1 / 10` | no invariant for the vulnerable function |
| 202311_grok | _transfer | `swapAmount <= taxAmount` | The predicates are not equivalent and neither is stronger. |
| 202404_HoppyFrogERC | _transfer | `swapAmount <= maxSwapForSell` | The predicates are not equivalent and neither is stronger. |
| 202406_APEMAGA | family | `msg.sender == account` | The predicates are not equivalent and neither is stronger. |
| 202408_OMPxContract | purchase | `block.timestamp >= lastInteractionTimestamp[msg.sender] + 30 seconds` | The predicates are not equivalent and neither is stronger. |
| 202409_Bedrock_DeFi | mint | `uniBTCAmount * 1e10 < msg.value` | The second predicate is stronger. |
| 202409_OnyxDAO | liquidateWithSingleRepay | `repayAmount == borrowedAmount` | no invariant for the vulnerable function |
| 202603_AlkemiEarn | liquidateBorrow | `msg.sender != targetAccount` | no invariant for the vulnerable function |

| Verdict | Count |
|---|---|
| The predicates are not equivalent and neither is stronger. | 16 |
| no invariant for the vulnerable function | 10 |
| no comparable invariant (all non-relational) | 1 |
| The second predicate is stronger. | 1 |

### Reading the results

- **16** predicates → `not equivalent / neither stronger`: InvCon+ produced
  invariants for the vulnerable function, but none of them matches (or implies,
  or is implied by) the patch's security guard.
- **10** predicates → `no invariant for the vulnerable function`: InvCon+
  produced no invariant at all for the vulnerable function, so it cannot, by
  construction, capture the security guard.
- **1** predicate → `no comparable invariant (all non-relational)` (Nimbus):
  InvCon+ produced only `one of [...]` / `Sum(...)` constructs, none comparable
  as a boolean predicate.
- **1** predicate → `second predicate is stronger` (`202409_Bedrock_DeFi`): the
  ground truth is stronger than the InvCon+ invariant, i.e. InvCon+ inferred
  only a weaker property than the one the patch enforces.

Across the whole dataset, InvCon+ never produced an invariant equivalent to or
stronger than a patch-derived security guard. In a large share of cases it
produced no invariant for the vulnerable function at all — note that some
contracts generate a very high number of invariants elsewhere
(e.g. `202404_HoppyFrogERC`: 7962, `202311_grok`: 3689), yet this volume does
not translate into capturing the security-relevant property.
