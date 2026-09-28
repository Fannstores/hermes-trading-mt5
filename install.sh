#!/usr/bin/env bash
set -euo pipefail

CONFIG=""
INSTALL_PREREQS=0
YES=0
SKIP_CHECK=0

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options]

Options:
  --config FILE          Copy an existing config file to ~/.hermes/trading-mt5.env
  --install-prereqs      Install missing common Linux prerequisites when a supported package manager is available
  --yes                  Allow prerequisite installation without an interactive confirmation
  --skip-check           Skip OS/MT5 environment detection
  -h, --help             Show this help

The installer never asks for or stores MT5 passwords or Telegram bot tokens.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config) CONFIG="${2:-}"; shift 2 ;;
    --install-prereqs) INSTALL_PREREQS=1; shift ;;
    --yes) YES=1; shift ;;
    --skip-check) SKIP_CHECK=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="${ROOT}/skills/trading/trading-mt5"
DEST="${HOME}/.hermes/skills/trading/trading-mt5"
STATE="${HOME}/.hermes/trading-mt5-state"

if [[ ! -f "${SOURCE}/SKILL.md" ]]; then
  echo "ERROR: Skill source not found: ${SOURCE}/SKILL.md" >&2
  echo "This repository must contain skills/trading/trading-mt5/SKILL.md." >&2
  exit 1
fi

OS="$(uname -s 2>/dev/null || echo unknown)"
ARCH="$(uname -m 2>/dev/null || echo unknown)"
WINE_BIN=""
MT5_PATH=""
MT5_STATUS="not_checked"
HERMES_PATH=""
PYTHON_PATH=""

find_mt5_linux() {
  local candidates=(
    "$HOME/.mt5/drive_c/Program Files/MetaTrader 5/terminal64.exe"
    "$HOME/.mt5/drive_c/Program Files/MetaTrader 5/terminal.exe"
    "$HOME/.wine/drive_c/Program Files/MetaTrader 5/terminal64.exe"
    "$HOME/.wine/drive_c/Program Files/MetaTrader 5/terminal.exe"
    "$HOME/.wine/drive_c/Program Files (x86)/MetaTrader 5/terminal.exe"
    "$HOME/.wine/drive_c/Program Files/MetaTrader 5/terminal64.exe"
  )
  local p
  for p in "${candidates[@]}"; do
    if [[ -f "$p" ]]; then echo "$p"; return 0; fi
  done

  local roots=("$HOME/.wine" "$HOME/.local/share/bottles" "$HOME/.var/app" "$HOME/.PlayOnLinux")
  for p in "${roots[@]}"; do
    [[ -d "$p" ]] || continue
    local hit
    hit="$(find "$p" -type f \( -iname 'terminal64.exe' -o -iname 'terminal.exe' \) -print -quit 2>/dev/null || true)"
    if [[ -n "$hit" ]]; then echo "$hit"; return 0; fi
  done
  return 1
}

find_mt5_windows() {
  command -v powershell.exe >/dev/null 2>&1 || return 1
  powershell.exe -NoProfile -NonInteractive -Command '
    $roots = @("$env:ProgramFiles", "${env:ProgramFiles(x86)}", "$env:LOCALAPPDATA", "$env:APPDATA");
    foreach ($r in $roots) {
      if ($r -and (Test-Path $r)) {
        $x = Get-ChildItem -Path $r -Filter terminal64.exe -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName;
        if ($x) { Write-Output $x; exit 0 }
      }
    }
    exit 1
  ' 2>/dev/null | head -n 1
}

install_linux_prereqs() {
  local missing=()
  command -v curl >/dev/null 2>&1 || missing+=(curl)
  command -v unzip >/dev/null 2>&1 || missing+=(unzip)
  command -v python3 >/dev/null 2>&1 || missing+=(python3)
  command -v git >/dev/null 2>&1 || missing+=(git)
  command -v wine >/dev/null 2>&1 || command -v wine64 >/dev/null 2>&1 || missing+=(wine)

  if ((${#missing[@]} == 0)); then
    echo "Prerequisites: OK"
    return 0
  fi

  echo "Missing common prerequisites: ${missing[*]}"
  [[ "$INSTALL_PREREQS" -eq 1 ]] || return 0
  [[ "$YES" -eq 1 ]] || {
    read -r -p "Install these prerequisites using the detected package manager? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || { echo "Prerequisite installation skipped."; return 0; }
  }

  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y "${missing[@]}"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "${missing[@]}"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --needed --noconfirm "${missing[@]}"
  else
    echo "No supported package manager found. Install missing prerequisites manually."
  fi
}

if command -v hermes >/dev/null 2>&1; then HERMES_PATH="$(command -v hermes)"; fi
if command -v python3 >/dev/null 2>&1; then PYTHON_PATH="$(command -v python3)"; fi

if [[ "$SKIP_CHECK" -eq 0 ]]; then
  echo "== Hermes Trading MT5 preflight =="
  echo "OS: ${OS}"
  echo "Architecture: ${ARCH}"
  [[ -n "$HERMES_PATH" ]] && echo "Hermes: ${HERMES_PATH}" || echo "Hermes: NOT FOUND"
  [[ -n "$PYTHON_PATH" ]] && echo "Python: ${PYTHON_PATH}" || echo "Python: NOT FOUND"

  case "$OS" in
    Linux*)
      if command -v wine64 >/dev/null 2>&1; then WINE_BIN="$(command -v wine64)";
      elif command -v wine >/dev/null 2>&1; then WINE_BIN="$(command -v wine)"; fi
      [[ -n "$WINE_BIN" ]] && echo "Wine: ${WINE_BIN}" || echo "Wine: NOT FOUND"
      if [[ -n "$WINE_BIN" ]]; then
        MT5_PATH="$(find_mt5_linux || true)"
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*)
      echo "Windows environment detected. Native MT5 lookup will be used; Wine is not required."
      MT5_PATH="$(find_mt5_windows || true)"
      ;;
    Darwin*)
      if command -v wine64 >/dev/null 2>&1; then WINE_BIN="$(command -v wine64)";
      elif command -v wine >/dev/null 2>&1; then WINE_BIN="$(command -v wine)"; fi
      [[ -n "$WINE_BIN" ]] && echo "Wine: ${WINE_BIN}" || echo "Wine: NOT FOUND"
      if [[ -n "$WINE_BIN" ]]; then MT5_PATH="$(find_mt5_linux || true)"; fi
      ;;
    *)
      echo "Unsupported/unknown shell OS: ${OS}. Continuing with skill installation only."
      ;;
  esac

  if [[ -n "$MT5_PATH" ]]; then
    MT5_STATUS="found"
    echo "MT5 terminal: FOUND -> ${MT5_PATH}"
  else
    MT5_STATUS="not_found"
    echo "MT5 terminal: NOT FOUND"
  fi

  if [[ "$OS" == Linux* ]]; then install_linux_prereqs; fi
else
  echo "Preflight skipped by request."
fi

mkdir -p "$DEST/references" "$DEST/scripts" "$STATE/strategies" "$STATE/cron" "$STATE/logs"
rm -f "$DEST/SKILL.md"
cp "$SOURCE/SKILL.md" "$DEST/SKILL.md"
rm -rf "$DEST/references" "$DEST/scripts"
mkdir -p "$DEST/references" "$DEST/scripts"
cp -R "$SOURCE/references/." "$DEST/references/"
cp -R "$SOURCE/scripts/." "$DEST/scripts/"
chmod +x "$DEST/scripts/"*.sh "$DEST/scripts/"*.py 2>/dev/null || true

if [[ -n "$CONFIG" ]]; then
  [[ -f "$CONFIG" ]] || { echo "ERROR: Config file not found: $CONFIG" >&2; exit 1; }
  cp "$CONFIG" "$HOME/.hermes/trading-mt5.env"
  chmod 600 "$HOME/.hermes/trading-mt5.env"
fi

if [[ -n "$MT5_PATH" ]]; then
  MT5_PATH_ESCAPED="$(printf '%s' "$MT5_PATH" | sed 's/\\/\\\\/g; s/"/\\"/g')"
else
  MT5_PATH_ESCAPED=""
fi
ENV_NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
{
  printf 'TRADING_MT5_OS=%q\n' "$OS"
  printf 'TRADING_MT5_ARCH=%q\n' "$ARCH"
  printf 'TRADING_MT5_HERMES=%q\n' "$HERMES_PATH"
  printf 'TRADING_MT5_PYTHON=%q\n' "$PYTHON_PATH"
  printf 'TRADING_MT5_WINE=%q\n' "$WINE_BIN"
  printf 'TRADING_MT5_TERMINAL=%q\n' "$MT5_PATH"
  printf 'TRADING_MT5_STATUS=%q\n' "$MT5_STATUS"
  printf 'TRADING_MT5_DETECTED_AT=%q\n' "$ENV_NOW"
} > "$STATE/environment.env"
chmod 600 "$STATE/environment.env"

if [[ -x "$DEST/scripts/validate_strategy.py" ]]; then
  EXAMPLE="${ROOT}/examples/strategies/SMC-SNR-FIB-v1.json"
  [[ -f "$EXAMPLE" ]] && "$PYTHON_PATH" "$DEST/scripts/validate_strategy.py" "$EXAMPLE" >/dev/null || true
fi

if [[ -z "$HERMES_PATH" ]]; then
  echo "WARNING: Hermes CLI was not found in PATH. Install Hermes first, then start a new session."
else
  echo "Hermes CLI detected: $HERMES_PATH"
fi

echo
echo "== Installation result =="
echo "Skill: INSTALLED -> $DEST"
echo "State: $STATE"
echo "Environment: $STATE/environment.env"
if [[ "$MT5_STATUS" == "found" ]]; then
  echo "MT5: FOUND"
  echo "Next: verify the terminal/account from Hermes before enabling trading."
else
  echo "MT5: NOT FOUND"
  echo "Next: install/locate MT5, then run the health/preflight check again."
fi
echo "Default safety: DEMO + READONLY + MANUAL."
echo "Secrets are never requested by this installer."
