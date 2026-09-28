# Trading MT5 scripts

- `mt5_preflight.sh`: reads the installer detection result and reports OS, Hermes, Python, Wine, and MT5 terminal status.
- `validate_strategy.py`: validates strategy manifest structure, including an explicit `risk.one_r` definition.
- `reconcile_managed_cron.sh`: prepares metadata for the managed evolution cron; it does not modify unrelated cron jobs.

These scripts are diagnostic/supporting tools. A filesystem-level MT5 detection is not the same as a successful broker login or verified order execution.
