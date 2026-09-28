# Setup and Recovery

## Setup order

```text
1. Inspect OS/runtime
2. Inspect Telegram credentials
3. Inspect persistent Telegram state
4. Verify Home Group
5. Verify MT5 filesystem/runtime
6. Verify broker authentication
7. Verify market data
8. Verify execution capability
9. Report exact status
```

These statuses are separate:

```text
filesystem_found
terminal_ready
broker_authenticated
market_data_ready
execution_verified
```

## Recovery

Never blindly repeat `/sethome`.

If user reports:

> `/sethome` sudah berhasil tapi Hermes masih meminta `/sethome`

run this diagnostic:

```text
persistent setup exists?
state == READY?
stored user id == current user id?
stored home chat id == current chat id?
role valid?
bot identity same?
```

If all pass, repair command routing instead of setup.

If persistence is missing, enter `REPAIR_REQUIRED`, explain what is missing, then rebuild the state once.

## Telegram bot behavior

The bot should acknowledge `/sethome` with a deterministic result and should read the persistent state on every process start.

Do not use conversation memory as the only source of Telegram setup state.

## MT5 setup

Do not assume MT5 is installed. Detect OS, Wine, terminal executable, account authentication, market data, and execution readiness separately. Never claim broker login is complete merely because a terminal executable exists.
