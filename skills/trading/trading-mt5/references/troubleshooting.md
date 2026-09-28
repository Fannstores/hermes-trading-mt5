# Troubleshooting

## MT5 connection

Check terminal process/service, bridge availability, account/server settings, and exact error output. Verify again after a fix.

## Order rejected

Do not retry blindly. Inspect symbol trade mode, volume step/min/max, stop level/freeze level, market state, margin, spread, and broker response.

## Telegram command ignored

Check Home Group, Telegram User ID authorization, role, bot permissions, and command registry. Do not treat group membership as authorization.

## Strategy test unavailable

Report missing dataset/engine/dependency. Do not fabricate backtest results.

## Cron mismatch

Only reconcile jobs with `MT5-EVO-MANAGED:v1`. Leave all unrelated jobs untouched.

Record new root causes and fixes here with date, environment, evidence, and verification result.
