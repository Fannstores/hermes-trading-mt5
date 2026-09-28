---
name: trading-mt5
description: Hermes skill untuk MetaTrader 5 dengan Telegram control plane, persistent setup state, command routing, research, strategy lifecycle, risk management, verified execution, journaling, and managed cron supervision.
version: 2.1.0
metadata:
  hermes:
    tags: [trading, mt5, forex, gold, telegram, strategy, backtest, research, risk, cron]
    category: trading
---

# Trading MT5 — Hermes Operating Skill

## 1. Non-negotiable rules

- Default: `MODE=demo`, `TRADING_MODE=manual`, `PERMISSION=readonly`.
- Never execute an order without permission, input validation, risk validation, and MT5 verification.
- `SENT` is not `EXECUTED`.
- Never claim success until MT5 read-back confirms the requested state.
- Never expose secrets in Telegram, logs, Git, or reports.
- Never overwrite an active strategy blindly.
- Never modify unrelated cron jobs.
- Never retry blindly after setup or execution failure.
- If information is missing, ask one precise question and WAIT.
- Telegram is a control plane; persistent state must live outside the chat session.

## 2. Telegram setup is a state machine

Use exactly these states:

```text
UNCONFIGURED
VERIFYING
READY
REPAIR_REQUIRED
```

Persistent Telegram setup record must contain at minimum:

```json
{
  "schema_version": 1,
  "state": "READY",
  "bot_id": "telegram-bot-id",
  "owner_user_id": "123",
  "home_chat_id": "-100123",
  "home_chat_type": "supergroup",
  "role": "owner",
  "verified_at": "ISO-8601",
  "updated_at": "ISO-8601"
}
```

Do not use a transient LLM/session variable as the source of truth.

### `/sethome`

`/sethome` is idempotent.

When received:

1. Read Telegram runtime identity: `from.id`, `chat.id`, `chat.type`.
2. Load persistent setup state.
3. If no state exists, validate and create it.
4. If state is `READY` and identity/chat match, return `ALREADY_READY` and do not restart setup.
5. If the same owner is setting a different chat as home, explicitly show old/new chat IDs and require confirmation before changing.
6. If unauthorized, reject without changing state.
7. Persist atomically.
8. Re-read the persisted state.
9. Return a concise verification summary.

Successful response must make the state explicit:

```text
TELEGRAM SETUP READY

User ID: <id>
Home Chat ID: <id>
Role: owner
State: READY

You do not need to run /sethome again.
```

### `/setupstatus`

Must read persistent state and report:

```text
State
User ID
Home Chat ID
Chat type
Role
Last verified time
Bot identity
```

If `READY`, it must not ask the user to run `/sethome`.

If state is missing but environment variables contain a Home Chat ID, reconcile them instead of blindly restarting setup.

## 3. Command routing

After Telegram authorization succeeds:

```text
Telegram update
→ identity extraction
→ persistent setup lookup
→ authorization
→ command parser
→ command handler
→ validation
→ risk/strategy policy
→ MT5 adapter
→ verification
→ journal
→ Telegram response
```

**Setup middleware must not loop back into setup after `READY`.**

Only these conditions may block routing:

- unauthorized user;
- unauthorized chat;
- `REPAIR_REQUIRED`;
- required runtime dependency unavailable;
- malformed command;
- risk/policy rejection.

A malformed trading command should return command-specific help, not `/sethome`.

## 4. `/entry`

Examples:

```text
/entry XAUUSD
```

Meaning: analysis/proposal only.

```text
/entry XAUUSD BUY LOT 0.05 SL 1 TP 2
```

Meaning: prepare a BUY request and pass it through validation/risk/execution policy.

```text
/entry XAUUSD BUY AUTOLOT RISK 1 SL 1 TP 2
```

Meaning: calculate lot from configured risk and validated SL distance.

Never guess missing side, lot, risk, or SL/TP.

`SL 1 TP 2` means 1R:2R. The strategy/risk configuration must define how 1R is calculated (ATR, structure, fixed distance, etc.).

## 5. Trading modes

```text
MANUAL
ASSISTED
AUTONOMOUS
```

`/stoptreding` and `/stoptrading` stop autonomous NEW entries. They do not automatically close open positions.

`/starttrading` re-enables autonomous NEW entries but does not force an entry.

REAL + AUTONOMOUS requires explicit `REAL_AUTONOMOUS_ENABLED=true` plus all other risk/permission requirements.

## 6. Risk

Validate at least:

- max risk/trade;
- max lot;
- max positions;
- daily loss;
- drawdown;
- spread;
- symbol;
- session;
- market data freshness;
- broker constraints;
- margin;
- strategy permission.

Auto lot must use actual account/broker metadata: balance/equity, tick value/size, contract size where applicable, lot min/max/step, SL distance, and margin.

## 7. Execution verification

Order lifecycle:

```text
REQUESTED
→ VALIDATING
→ APPROVED
→ SENT
→ ACKNOWLEDGED
→ EXECUTED
```

Failure states:

```text
FAILED
REJECTED
TIMEOUT
```

Never collapse these into one generic success/failure state.

## 8. Strategy lifecycle

```text
IDEA → HYPOTHESIS → IMPLEMENTATION → BACKTEST
→ OUT-OF-SAMPLE → DEMO → CANDIDATE → PROMOTED → RETIRED
```

Commands:

```text
/strategienew
/strategyimprove
/strategytest
/strategycompare
/strategypromote
/strategyretire
/strategyarchive
/strategydelete
/strategyrollback
```

Delete requires confirmation and must preserve history/archive.

## 9. Research

For fundamental/news research use web/browser sources with source URL/title and timestamp. Never invent unavailable market or news data.

## 10. Managed cron

Managed cron marker:

```text
MT5-EVO-MANAGED:v1
```

Only manage the cron entry carrying that marker. Never delete or rewrite unrelated user cron jobs.

## 11. Failure handling

When a command fails:

1. capture the exact failing stage;
2. classify the failure;
3. inspect state/dependency;
4. apply the smallest safe fix;
5. verify again;
6. report the actual result.

Do not ask the user to repeat successful setup steps unless verification proves the persistent state is missing or invalid.
