#!/usr/bin/env python3
"""Validate a strategy manifest without executing trades."""
import json, sys

REQ = ["id", "version", "status", "symbols", "timeframes", "entry", "exit", "risk"]

def main():
    if len(sys.argv) != 2:
        print("usage: validate_strategy.py STRATEGY.json", file=sys.stderr)
        return 2
    with open(sys.argv[1], encoding="utf-8") as f:
        d = json.load(f)
    missing = [k for k in REQ if k not in d]
    if missing:
        print("INVALID: missing " + ", ".join(missing))
        return 1
    if not isinstance(d["symbols"], list) or not d["symbols"]:
        print("INVALID: symbols must be non-empty list")
        return 1
    risk = d["risk"]
    if "one_r" not in risk:
        print("INVALID: risk.one_r must explicitly define 1R")
        return 1
    print(f"VALID: {d['id']} {d['version']} status={d['status']} 1R={risk['one_r']}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
