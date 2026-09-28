# Strategy Lifecycle and Evolution

## Lifecycle

`IDEA -> HYPOTHESIS -> IMPLEMENTATION -> BACKTEST -> OUT-OF-SAMPLE -> DEMO -> CANDIDATE -> PROMOTED -> RETIRED`

## `/strateginew`

Input is natural language. Hermes converts it into a structured hypothesis with:

- objective
- market/symbols
- timeframe(s)
- entry conditions
- exit conditions
- filters
- risk model
- 1R definition
- assumptions
- data requirements
- falsification criteria
- test plan

Example:

`/strateginew coba SMC + SNR + Fibonacci untuk XAUUSD, H1 bias dan M15 entry`

The result is not promoted automatically.

## `/strategyimprove`

Create a new version. State what changed and why. Link the evidence.

## Anti-overfitting

Require separation of development and validation data. Avoid optimizing repeatedly on the same OOS period. Prefer robust parameter ranges over a single magic value. Record sample size and test period.

## Promotion

Promotion requires explicit gates defined by project policy, such as minimum sample size, drawdown limit, robustness checks, OOS result, and forward/demo evidence. Do not invent thresholds if the user has not defined them.

## Delete/archive

Archive preserves history. Delete requires confirmation and must not delete audit evidence required by retention policy.
