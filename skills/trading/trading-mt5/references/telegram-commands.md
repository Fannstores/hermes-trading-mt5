# Telegram Commands

## Setup

| Command | Function |
|---|---|
| `/start` | Show current status/menu; never reset valid setup |
| `/sethome` | Configure/verify Home Group; idempotent |
| `/setupstatus` | Show persistent setup state |
| `/status` | Show Telegram + MT5 + trading status |
| `/helptrading` | Show only implemented trading commands |

## Trading

```text
/analisis XAUUSD
/entry XAUUSD
/entry XAUUSD BUY LOT 0.05 SL 1 TP 2
/entry XAUUSD BUY AUTOLOT RISK 1 SL 1 TP 2
/positions
/closeentry
/closeall
/starttrading
/stoptreding
/stoptrading
```

### Important routing rule

Once setup state is `READY`, all authorized commands must bypass setup and enter their handler.

`/entry` must never require `/sethome` again merely because a new Telegram message arrived.

### `/entry XAUUSD`

Analysis/proposal only.

### `/entry XAUUSD BUY LOT 0.05 SL 1 TP 2`

Request flow:

```text
parse
→ validate
→ permission
→ strategy/risk
→ preview/confirmation if required
→ MT5
→ read-back
→ journal
```

### `/closeentry`

If multiple open positions exist, ask which position. Do not guess.

### `/closeall`

Always require explicit confirmation before closing positions unless an emergency policy explicitly defines otherwise.

## Setup error responses

Do not use generic setup errors.

Bad:

```text
Please run /sethome first.
```

when state is READY.

Good:

```text
SETUP READY
User authorization: PASS
Home Group: PASS
Command: /entry
Router: BLOCKED
Reason: MT5 is not connected
```

## v8 command registration

The v8 package installs `hermes-trading-mt5-command-router` as a native Hermes plugin. This is required because SKILL.md installation alone exposes `/trading-mt5`, not arbitrary `/entry`-style commands. The plugin registers the commands through `ctx.register_command()` and routes them into the same gateway session. The installer enables gateway injection and prioritizes the commands in the Telegram menu.
