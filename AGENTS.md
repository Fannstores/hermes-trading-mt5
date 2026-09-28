# AGENTS.md — Hermes Trading MT5

## Tujuan
Pasang dan operasikan skill trading MT5 secara stateful, aman, dapat diverifikasi, dan tidak mengganggu cron/job milik user lain.

## Aturan setup
1. PREFLIGHT: cek OS, architecture, Hermes, Python, MT5/bridge, Telegram capability, storage.
2. Untuk Linux/macOS, deteksi Wine sebelum menganggap MT5 siap. Untuk Windows native, deteksi MT5 native; jangan menggunakan Wine tanpa alasan.
3. Bedakan `MT5 filesystem FOUND` dari `broker login/market-data READY`; keduanya wajib diverifikasi terpisah.
4. Jika dependency sistem hilang, tawarkan safe fix yang jelas; jangan memasang software diam-diam.
5. DISCOVERY: cari konfigurasi yang sudah ada sebelum meminta ulang.
6. ASK ONE QUESTION: bila data wajib hilang, tanya satu pertanyaan jelas dengan opsi.
7. WAIT: jangan lanjut sebelum user menjawab.
8. APPLY: ubah hanya komponen yang dibutuhkan.
9. VERIFY: baca kembali hasil konfigurasi/service.

Jangan menebak broker, login, symbol, risk, mode REAL, definisi 1R, atau izin autonomous.

## Recovery
Jika gagal: diagnose -> safe fix -> verify. Jangan blind retry command yang sama. Jangan klaim sukses tanpa bukti.

## Trading safety
- Default DEMO + MANUAL/READONLY.
- REAL autonomous execution harus explicit.
- Setiap entry harus melewati permission, validation, strategy, risk, MT5 execution, dan verification.
- `/stoptreding` menghentikan autonomous entry baru; tidak menutup posisi terbuka.
- `SL 1 TP 2` adalah 1R:2R; sumber 1R wajib eksplisit di strategy.

## Strategy evolution
Gunakan lifecycle dan versioning. Jangan overwrite active strategy. `/strateginew` membuat hypothesis/version baru; tidak langsung mempromosikannya.

## Cron
Managed supervisor:
- Name: MT5-EVO-SUPERVISOR
- Marker: MT5-EVO-MANAGED:v1

Hanya cron dengan marker tersebut yang boleh direkonsiliasi oleh skill.
