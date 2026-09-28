#!/usr/bin/env bash
set -euo pipefail
NAME="MT5-EVO-SUPERVISOR"
MARKER="MT5-EVO-MANAGED:v1"
STATE="${HOME}/.hermes/trading-mt5-state/cron/managed-supervisor.json"
mkdir -p "$(dirname "$STATE")"
cat > "$STATE" <<JSON
{
  "name": "$NAME",
  "marker": "$MARKER",
  "scope": "only this managed job may be reconciled by trading-mt5",
  "verified": false
}
JSON
printf 'Managed cron metadata prepared: %s (%s)\n' "$NAME" "$MARKER"
printf '%s\n' 'Use the Hermes cron interface for actual scheduling; do not modify unrelated cron jobs.'
