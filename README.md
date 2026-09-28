# Hermes Trading MT5

Hermes skill + native Hermes plugin untuk MetaTrader 5 dengan Telegram sebagai control plane.

## Apa yang diperbaiki di v8

v8 memperbaiki masalah `/entry` dan command trading yang tidak muncul di Telegram.

`SKILL.md` hanya membuat command skill `/trading-mt5`. Command seperti `/entry` harus didaftarkan melalui native Hermes plugin registry. v8 menambahkan plugin `hermes-trading-mt5-command-router` yang memakai `ctx.register_command()`, sehingga command masuk ke registry Hermes dan tersedia di gateway Telegram.

Setiap command diteruskan ke session Telegram yang sama sebagai user turn. Skill `trading-mt5` tetap menjadi sumber kebenaran untuk authorization, setup state, strategy, risk, execution, verification, dan journal.

Hermes mendokumentasikan bahwa `ctx.register_command()` membuat slash command di CLI dan gateway, termasuk Telegram, serta command tersebut muncul di autocomplete, `/help`, dan menu bot Telegram. citehttps://github.com/NousResearch/hermes-agent/blob/main/website/docs/developer-guide/plugins/index.md

## Install

Dari folder hasil ekstrak:

```bash
chmod +x install.sh
./install.sh
```

Installer memasang:

```text
$HERMES_HOME/skills/trading/trading-mt5/
$HERMES_HOME/plugins/hermes-trading-mt5-command-router/
```

`HERMES_HOME` mengikuti environment Hermes. Jika tidak diset, default-nya `~/.hermes`.

Installer juga:

- mengaktifkan plugin melalui `hermes plugins enable`;
- memberi grant `allow_gateway_injection` yang diperlukan plugin untuk meneruskan command ke session Telegram yang sedang aktif;
- memprioritaskan command MT5 di `platforms.telegram.extra.command_menu` agar tidak terpotong oleh batas menu Telegram/Hermes.

Hermes memang membangun menu Telegram dari central slash-command registry dan membatasi menu default sampai 60 command; command lokal/plugin dapat diprioritaskan melalui `command_menu.priority`. citehttps://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/messaging/telegram.md

## Setelah install

Restart gateway Hermes.

```bash
hermes gateway restart
```

Lalu di Telegram:

```text
/
```

Command MT5 harus muncul.

Untuk melihat registry dari Hermes:

```text
/commands
```

## Command Telegram

```text
/sethome
/setupstatus
/status
/helptrading
/analisis XAUUSD
/entry XAUUSD
/entry XAUUSD BUY LOT 0.05 SL 1 TP 2
/positions
/closeentry
/closeall
/starttrading
/stoptreding
/stoptrading

/strategienew
/strategyimprove
/strategytest
/strategycompare
/strategypromote
/strategyretire
/strategyarchive
/strategydelete
/strategyrollback

/research
/goal
/cron
```

`/entry XAUUSD` tanpa side/lot adalah analisis/proposal. Hermes tidak boleh menebak parameter entry.

`SL 1 TP 2` berarti risk/reward 1R:2R. Jarak 1R harus ditentukan oleh strategy/risk configuration, misalnya ATR, structure, atau fixed distance.

## Telegram setup

1. Pastikan Telegram gateway Hermes aktif.
2. Pastikan bot memiliki token yang benar.
3. Pastikan Telegram user/chat diizinkan oleh konfigurasi Hermes.
4. Jalankan `/sethome` dari Home Group satu kali.
5. Jalankan `/setupstatus`.
6. Jika status `READY`, `/sethome` tidak perlu diulang.
7. Ketik `/` dan pastikan command MT5 terlihat.

Telegram menggunakan user ID numerik untuk authorization. Hermes juga memiliki pemisahan admin dan regular-user untuk slash command melalui `allow_admin_from`, `user_allowed_commands`, dan konfigurasi group yang sesuai. citehttps://github.com/NousResearch/hermes-agent/blob/main/website/docs/reference/slash-commands.md

## Jika command terdaftar tetapi tidak terlihat

Cek:

```bash
hermes plugins list
hermes config get platforms.telegram.extra.command_menu --json
```

Pastikan:

```text
hermes-trading-mt5-command-router = enabled
```

Jika slash-command access control diaktifkan, pastikan user/admin scope mengizinkan command tersebut. `/whoami` dapat digunakan untuk melihat tier dan command yang boleh dijalankan. citehttps://github.com/NousResearch/hermes-agent/blob/main/website/docs/reference/slash-commands.md

## Jika command muncul tetapi tidak dieksekusi

Periksa gateway log:

```bash
hermes logs --level WARNING | grep -i -E 'plugin|trading|telegram'
```

Kemudian cek:

```text
/setupstatus
/status
```

Jangan mengulang `/sethome` secara membabi buta. Jika state rusak, diagnosis state terlebih dahulu.

## Safe defaults

```text
MODE=demo
TRADING_MODE=manual
PERMISSION=readonly
REAL_AUTONOMOUS_ENABLED=false
```

Tidak ada order yang boleh dieksekusi tanpa permission, validation, risk checks, dan verification/read-back dari MT5.

## Strategy lifecycle

```text
IDEA → HYPOTHESIS → IMPLEMENTATION → BACKTEST → OUT-OF-SAMPLE → DEMO → CANDIDATE → PROMOTED → RETIRED
```

Strategy harus versioned. Active version tidak boleh ditimpa secara buta. Perubahan harus memiliki evidence, test, dan rollback path.

## SMC + SNR + Fibonacci

Contoh strategy awal tersedia di:

```text
examples/strategies/SMC-SNR-FIB-v1.json
```

Strategy ini adalah contoh hypothesis, bukan jaminan profit dan bukan instruksi untuk langsung memakai akun REAL.

## Arsitektur command

```text
Telegram
   ↓
Hermes gateway
   ↓
Central command registry
   ↓
hermes-trading-mt5-command-router
   ↓
existing Telegram session
   ↓
trading-mt5 skill
   ↓
authorization → validation → risk → MT5 → verification → journal
```

Plugin tidak menyimpan trading state sebagai sumber kebenaran dan tidak membuat jalur eksekusi alternatif yang melewati risk engine.

## Struktur

```text
hermes-trading-mt5/
├── AGENTS.md
├── README.md
├── config.example.env
├── install.sh
├── examples/
│   └── strategies/
│       └── SMC-SNR-FIB-v1.json
├── plugins/
│   └── hermes-trading-mt5-command-router/
│       ├── plugin.yaml
│       └── __init__.py
└── skills/
    └── trading/
        └── trading-mt5/
            ├── SKILL.md
            ├── references/
            └── scripts/
```

## Official Hermes references

- Plugins and slash commands: urlHermes Plugin Guidehttps://github.com/NousResearch/hermes-agent/blob/main/website/docs/developer-guide/plugins/index.md
- Telegram command menu: urlHermes Telegram Guidehttps://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/messaging/telegram.md
- Slash-command permissions: urlHermes Slash Commands Referencehttps://github.com/NousResearch/hermes-agent/blob/main/website/docs/reference/slash-commands.md

## Important

v8 memperbaiki **registrasi dan routing slash command**. Ini tidak mengubah batas keamanan trading: mode REAL/autonomous tetap harus di-enable secara eksplisit dan semua order harus melewati risk/validation/verification.
