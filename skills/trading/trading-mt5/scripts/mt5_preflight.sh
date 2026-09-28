#!/usr/bin/env bash
set -euo pipefail

STATE="${HOME}/.hermes/trading-mt5-state"
ENV_FILE="${STATE}/environment.env"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
else
  echo "Preflight state not found: $ENV_FILE"
  echo "Run the repository install.sh first."
  exit 1
fi

printf 'OS: %s\n' "${TRADING_MT5_OS:-unknown}"
printf 'Architecture: %s\n' "${TRADING_MT5_ARCH:-unknown}"
printf 'Hermes: %s\n' "${TRADING_MT5_HERMES:-NOT FOUND}"
printf 'Python: %s\n' "${TRADING_MT5_PYTHON:-NOT FOUND}"
printf 'Wine: %s\n' "${TRADING_MT5_WINE:-NOT REQUIRED/NOT FOUND}"
printf 'MT5 terminal: %s\n' "${TRADING_MT5_TERMINAL:-NOT FOUND}"
printf 'MT5 detection: %s\n' "${TRADING_MT5_STATUS:-unknown}"

if [[ "${TRADING_MT5_STATUS:-}" != "found" ]]; then
  echo
  echo "MT5 is not ready at the filesystem level. Do not enable autonomous trading."
  exit 2
fi

echo
echo "Filesystem preflight: PASS"
echo "This does not prove broker login, market-data availability, or order execution."
