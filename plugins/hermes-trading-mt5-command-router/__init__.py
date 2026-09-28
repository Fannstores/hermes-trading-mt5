"""Hermes Trading MT5 slash-command bridge.

Registers the operator-facing Telegram/CLI slash commands.  Each command is
forwarded into the existing gateway session as a normal user turn so the
installed trading-mt5 skill remains the source of truth for authorization,
risk, execution, verification, and journaling.
"""
from __future__ import annotations

import contextvars

_SESSION_KEY = contextvars.ContextVar("trading_session_key", default=None)

_COMMANDS = {
    "sethome": "Set and verify the Telegram Home Group",
    "setupstatus": "Show persistent Telegram setup state",
    "status": "Show MT5, Telegram, risk, and trading status",
    "helptrading": "Show implemented MT5 trading commands",
    "analisis": "Analyze technical, fundamental, news, calendar, session, strategy, and risk",
    "entry": "Create or analyze an MT5 entry request",
    "positions": "Show open MT5 positions",
    "closeentry": "Close one selected MT5 position",
    "closeall": "Close all MT5 positions after confirmation",
    "starttrading": "Enable autonomous new entries without forcing an entry",
    "stoptreding": "Stop autonomous new entries; do not close positions",
    "stoptrading": "Alias for /stoptreding",
    "strategienew": "Create a new strategy hypothesis/version",
    "strategyimprove": "Improve an existing strategy using evidence",
    "strategytest": "Backtest or test a strategy",
    "strategycompare": "Compare strategy versions without ranking them",
    "strategypromote": "Promote a strategy after required evidence",
    "strategyretire": "Retire a strategy",
    "strategyarchive": "Archive a strategy/version",
    "strategydelete": "Delete an inactive strategy after confirmation",
    "strategyrollback": "Rollback to a preserved strategy version",
    "research": "Run fundamental/news research with sources and timestamps",
    "goal": "Set or inspect the MT5 evolution goal",
    "cron": "Inspect or reconcile the managed MT5 evolution cron",
}

_ARG_COMMANDS = {
    "entry", "analisis", "research", "strategienew", "strategyimprove",
    "strategytest", "strategycompare", "strategypromote", "strategyretire",
    "strategyarchive", "strategydelete", "strategyrollback", "goal", "cron",
}


def _capture_session(*, session_key=None, platform=None, **_kwargs):
    """Capture the durable gateway session key for the current command."""
    if platform == "telegram" and session_key:
        _SESSION_KEY.set(session_key)


def _make_handler(ctx, name: str):
    def handler(raw_args: str):
        session_key = _SESSION_KEY.get()
        if not session_key:
            return (
                f"/{name} terdaftar, tetapi session Telegram aktif tidak ditemukan. "
                "Jalankan /status lalu coba lagi."
            )

        args = raw_args.strip()
        request = (
            "Handle the following Hermes Trading MT5 command using the installed "
            "trading-mt5 skill. Keep the command semantics exactly as documented; "
            "do not invent missing parameters. Command: /" + name
        )
        if args:
            request += " " + args

        if ctx.inject_message(request, role="user", session_key=session_key):
            return None
        return f"/{name} gagal diteruskan ke session Telegram aktif. Cek gateway log."

    handler.__name__ = f"handle_{name}"
    return handler


def register(ctx):
    ctx.register_hook("pre_command", _capture_session)
    for name, description in _COMMANDS.items():
        ctx.register_command(
            name,
            handler=_make_handler(ctx, name),
            description=description,
            args_hint="<args>" if name in _ARG_COMMANDS else "",
        )
