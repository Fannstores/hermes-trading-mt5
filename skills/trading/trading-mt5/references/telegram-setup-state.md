# Telegram Setup State Contract

This file is authoritative for the Telegram setup loop problem.

## State machine

```text
UNCONFIGURED
    |
    | /sethome
    v
VERIFYING
    |
    | persist + read-back success
    v
READY

READY
  | \\
  |  \\ invalid/missing persistent record
  |   \\
  |    v
  |  REPAIR_REQUIRED
  |
  +--> normal command routing
```

## Required identity fields

Use Telegram runtime update fields:

```text
from.id       = Telegram User ID
chat.id       = Chat ID
chat.type     = private/group/supergroup/channel
```

Do not identify a user using username.

## Persistence

The setup record must survive LLM/session restart, bot restart, process restart, `/start`, and normal command processing.

Preferred path:

```text
state/telegram/setup.json
```

If the host application uses a database, the database is authoritative instead.

## Idempotency

If `/sethome` is executed while state is already valid:

```text
Result: ALREADY_READY
```

Do not delete/recreate the record.

If `/entry` arrives while state is `READY`, the setup middleware MUST return control to the command router.

## Routing guard

Pseudo-flow:

```text
setup = loadSetup()

if setup.state == READY:
    if authorized(update, setup):
        routeCommand(update)
    else:
        rejectUnauthorized()
elif setup.state == UNCONFIGURED:
    if command == /sethome:
        runSetHome()
    else:
        explainOneTimeSetup()
elif setup.state == REPAIR_REQUIRED:
    diagnoseAndRepair()
else:
    verifySetup()
```

Critical invariant:

```text
READY + authorized != setup flow
READY + authorized == command router
```

## `/entry` diagnostic

If `/entry XAUUSD` is not handled:

1. Read setup state.
2. Read current Telegram user ID/chat ID.
3. Compare with persistent state.
4. If they match and state is READY, inspect command parser/handler registration.
5. Do NOT ask for `/sethome`.
6. Return the actual blocking reason.

Example:

```text
ENTRY NOT ROUTED

Telegram setup: READY
User authorization: PASS
Home chat: PASS
Command parser: /entry recognized
Trading handler: NOT REGISTERED

Next action: repair command handler registration.
```

## Unauthorized group

Being a member of a group is not sufficient. Authorization requires the stored User ID + Home Chat ID + role/policy.

## Private chat

If the configured Home Group is a group/supergroup, a private-chat `/entry` should not silently become authorized. Return:

```text
This command is restricted to the configured Home Group.
```

unless a separate private-chat policy explicitly allows it.
