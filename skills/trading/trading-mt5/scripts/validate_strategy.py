#!/usr/bin/env python3
import json, sys
if len(sys.argv) != 2: raise SystemExit("usage: validate_strategy.py <strategy.json>")
with open(sys.argv[1], encoding="utf-8") as f: data=json.load(f)
required=["id","name","version","status"]
missing=[k for k in required if k not in data]
if missing: raise SystemExit("INVALID: missing "+", ".join(missing))
print(f"VALID: {data['id']} {data['version']} status={data['status']}")
