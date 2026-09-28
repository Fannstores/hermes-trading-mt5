#!/usr/bin/env bash
set -u
echo "== MT5 preflight =="
case "$(uname -s 2>/dev/null || true)" in
  Linux*) echo "OS: Linux"; command -v wine >/dev/null 2>&1 && echo "Wine: found" || echo "Wine: not found";;
  Darwin*) echo "OS: macOS"; command -v wine >/dev/null 2>&1 && echo "Wine: found" || echo "Wine: not found";;
  MINGW*|MSYS*|CYGWIN*) echo "OS: Windows-compatible shell";;
  *) echo "OS: unknown";;
esac
found=0
for p in "$HOME/.mt5/drive_c/Program Files/MetaTrader 5/terminal64.exe" "$HOME/.wine/drive_c/Program Files/MetaTrader 5/terminal64.exe" "$HOME/.wine/drive_c/Program Files/MetaTrader 5/terminal.exe"; do
  if [ -f "$p" ]; then echo "Terminal: found -> $p"; found=1; fi
done
[ "$found" -eq 1 ] || echo "Terminal: filesystem executable not found"
echo "Filesystem detection is not broker authentication."
echo "Filesystem detection is not market-data readiness."
echo "Filesystem detection is not execution verification."
