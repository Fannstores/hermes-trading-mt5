---
name: trading-mt5
description: Hermes skill untuk MetaTrader 5: Telegram command control, technical/fundamental research, strategy development/evolution, risk management, verified execution, journaling, and managed cron supervision.
version: 2.0.0
metadata:
  hermes:
    tags: [trading, mt5, forex, gold, telegram, strategy, backtest, research, risk, cron]
    category: trading
---

# Trading MT5

Gunakan skill ini untuk operasi MT5, analisis, research, strategy development, execution, risk control, journaling, dan evolution.

## Hard rules

1. Default `MODE=demo`, `TRADING_MODE=manual`, `PERMISSION=readonly`.
2. `REAL_AUTONOMOUS_ENABLED` harus explicit `true` sebelum autonomous REAL execution.
3. Tidak ada order tanpa permission + validation + risk checks.
4. Tidak pernah menyatakan order sukses tanpa read-back/verifikasi MT5.
5. Jangan meminta/mencetak password, API token, atau secret di Telegram/log.
6. `/stoptreding` dan `/stoptrading` hanya memblokir autonomous NEW ENTRY. Jangan menutup posisi terbuka.
7. `SL 1 TP 2` selalu berarti `1R:2R`; definisi 1R harus berasal dari strategy config.
8. Jika data penting hilang, tanya user dan WAIT. Jangan menebak.
9. Jika gagal, diagnose root cause; jangan blind retry.
10. Jangan menyentuh cron yang tidak memiliki `MT5-EVO-MANAGED:v1`.
11. Jangan overwrite active strategy. Perubahan menghasilkan version baru.
12. `/helptrading` hanya boleh menampilkan command yang terdaftar di registry/implemented handler.

## Command dispatch

Semua input Telegram dan autonomous trigger wajib melewati satu command/operation layer:

`parser -> registry -> auth -> validation -> strategy -> risk -> MT5 adapter -> verification -> journal -> response`

Bot tidak boleh mempunyai jalur khusus yang melewati risk engine.

## Setup

Ikuti `references/setup-and-recovery.md` dan perlakukan hasil installer sebagai **preflight evidence**, bukan bukti broker-ready.

Urutan wajib:

1. Deteksi OS dan architecture.
2. Deteksi Hermes CLI dan runtime yang dibutuhkan.
3. Linux/macOS: deteksi Wine terlebih dahulu; Windows native: deteksi MT5 native.
4. Deteksi terminal MT5 (`terminal64.exe`/`terminal.exe`) pada lokasi/prefix yang ditemukan.
5. Jika terminal tidak ditemukan, jelaskan dependency yang hilang dan jangan mengklaim MT5 siap.
6. Jika terminal ditemukan, lanjutkan discovery broker/account/bridge/market-data.
7. Bedakan status `filesystem_found`, `terminal_ready`, `broker_authenticated`, `market_data_ready`, dan `execution_verified`.
8. Jika informasi konfigurasi penting belum tersedia, ASK ONE QUESTION lalu WAIT.
9. Setelah APPLY, selalu VERIFY dengan read-back.

Script preflight tersedia di `scripts/mt5_preflight.sh`. Script ini hanya memeriksa environment/filesystem; login broker dan execution tetap harus diverifikasi oleh Hermes/MT5 adapter.

## Telegram

Home group dibuat dengan `/sethome`. Authorization memakai Telegram User ID + Home Group ID + role. Group membership bukan permission.

## Research

Untuk fundamental/news/economic context, gunakan browser/web bila tersedia. Catat source URL/name, publication time, market-data time, dan limitations. Jangan mengarang source atau data.

## Strategy development

`/strateginew` membuat hypothesis baru dari instruksi natural language. Contoh:

`/strateginew Coba buat metode SMC + SNR + Fibonacci untuk XAUUSD. H1 bias, M15 entry. Research, backtest, OOS, demo dulu.`

Treat the requested method as a hypothesis, not proof of profitability.

Lifecycle:

`IDEA -> HYPOTHESIS -> IMPLEMENTATION -> BACKTEST -> OUT-OF-SAMPLE -> DEMO -> CANDIDATE -> PROMOTED -> RETIRED`

Setiap perubahan strategy menghasilkan version baru dan change log.

## Risk

Minimal checks: risk/trade, lot, positions, daily loss, drawdown, spread, margin, stale data, session, duplicate order, broker errors, kill switch.

Auto lot harus menggunakan balance/equity, risk %, SL distance, tick value/size, contract constraints, and margin requirements.

## SL/TP

Untuk BUY:

`SL = entry - R_distance`
`TP = entry + (TP_R * R_distance)`

Untuk SELL:

`SL = entry + R_distance`
`TP = entry - (TP_R * R_distance)`

`R_distance` berasal dari strategy. Validasi broker stop-level/freeze-level sebelum modify.

## Cron supervisor

Name: `MT5-EVO-SUPERVISOR`

Marker: `MT5-EVO-MANAGED:v1`

Reconcile only managed cron. If objective changes, remove/update only the old managed job and create the new managed job. Verify result.

## Persistent state

Default state root: `~/.hermes/trading-mt5-state/`.

Use structured JSON/Markdown for setup, goals, experiments, lessons, strategies, trades, research, and cron metadata.

## Documentation

See:
- `references/telegram-commands.md`
- `references/setup-and-recovery.md`
- `references/strategy-lifecycle.md`
- `references/fundamental-research.md`
- `references/cron-goal-reconciliation.md`
- `references/troubleshooting.md`
