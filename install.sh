#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
SKILL_SRC="${ROOT}/skills/trading/trading-mt5"
SKILL_DEST="${HERMES_HOME}/skills/trading/trading-mt5"
PLUGIN_SRC="${ROOT}/plugins/hermes-trading-mt5-command-router"
PLUGIN_NAME="hermes-trading-mt5-command-router"
PLUGIN_DEST="${HERMES_HOME}/plugins/${PLUGIN_NAME}"

if [[ ! -f "${SKILL_SRC}/SKILL.md" ]]; then
  echo "ERROR: missing ${SKILL_SRC}/SKILL.md" >&2
  exit 1
fi
if [[ ! -f "${PLUGIN_SRC}/plugin.yaml" || ! -f "${PLUGIN_SRC}/__init__.py" ]]; then
  echo "ERROR: invalid command-router plugin package" >&2
  exit 1
fi

mkdir -p "$(dirname "${SKILL_DEST}")" "$(dirname "${PLUGIN_DEST}")"
rm -rf "${SKILL_DEST}" "${PLUGIN_DEST}"
cp -a "${SKILL_SRC}" "${SKILL_DEST}"
cp -a "${PLUGIN_SRC}" "${PLUGIN_DEST}"

if ! command -v hermes >/dev/null 2>&1; then
  echo "ERROR: hermes command not found. Install Hermes first, then rerun ./install.sh." >&2
  exit 1
fi

# Native Hermes plugin lifecycle: enable the plugin explicitly.
hermes plugins enable "${PLUGIN_NAME}"

# Gateway injection is required because the slash-command handler forwards the
# request into the same Telegram conversation. Fail closed if this cannot be set.
hermes config set "plugins.entries.${PLUGIN_NAME}.allow_gateway_injection" true

# Keep MT5 commands inside Telegram's visible command-menu cap.
PRIORITY='[sethome, setupstatus, status, helptrading, analisis, entry, positions, closeentry, closeall, starttrading, stoptreding, stoptrading, strategienew, strategyimprove, strategytest, strategycompare, strategypromote, strategyretire, strategyarchive, strategydelete, strategyrollback, research, goal, cron]'
hermes config set platforms.telegram.extra.command_menu.max_commands 60
hermes config set platforms.telegram.extra.command_menu.priority_mode prepend
hermes config set platforms.telegram.extra.command_menu.priority "${PRIORITY}"

cat <<EOF

Hermes Trading MT5 installed.

Skill : ${SKILL_DEST}
Plugin: ${PLUGIN_DEST}

Registered Telegram commands:
  /sethome /setupstatus /status /helptrading /analisis /entry /positions
  /closeentry /closeall /starttrading /stoptreding /stoptrading
  /strategienew /strategyimprove /strategytest /strategycompare /strategypromote
  /strategyretire /strategyarchive /strategydelete /strategyrollback
  /research /goal /cron

Restart the Hermes gateway after installation.
Then type / in Telegram. The commands are registered by the Hermes plugin
registry and prioritized in the Telegram command menu.
EOF
