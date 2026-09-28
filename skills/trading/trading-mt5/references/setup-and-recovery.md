# Setup and Recovery

## Setup state machine

```text
PREFLIGHT -> DISCOVERY -> ASK -> WAIT -> APPLY -> VERIFY -> READY
```

### PREFLIGHT

Check:
- Linux architecture and supported runtime.
- Hermes version/capabilities.
- MT5 terminal/bridge availability.
- Python/runtime dependencies.
- Telegram capability.
- write access to state root.
- existing configuration.

### DISCOVERY

Read existing state first. Never ask for values already known and verified.

### ASK/WAIT

Ask exactly one blocking question at a time. Examples:
- Demo or Real?
- Manual, Assisted, or Autonomous?
- What is the broker/server and account login?
- What defines 1R: ATR, structure, or fixed distance?
- Is REAL autonomous execution explicitly allowed?

Do not continue until answered.

### APPLY

Apply the minimum change. Preserve existing state and unrelated cron.

### VERIFY

Read back configuration and test the relevant component. For MT5 execution, verify order ticket/status/SL/TP from MT5.

## Recovery rules

1. Capture exact error.
2. Identify root cause.
3. Apply only a safe/reversible fix.
4. Re-run a changed check, not an identical blind retry.
5. Verify.
6. If blocked, ask user for the missing external action.

Never say "berhasil" unless the verification evidence exists.
