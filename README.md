# Hermes Trading MT5

Skill Hermes untuk mengoperasikan, meneliti, menguji, dan mengembangkan trading MetaTrader 5 dengan Telegram sebagai control plane.

> **Safe default:** DEMO + READONLY + MANUAL. Installer tidak meminta password MT5 atau Telegram Bot Token. Tidak ada klaim order berhasil tanpa read-back dari MT5.

## Apa yang dilakukan project ini

- Mengajarkan Hermes workflow trading MT5: analysis, research, strategy development, risk, execution, journaling, dan evolution.
- Mendeteksi environment sebelum setup: OS, architecture, Hermes CLI, Python, Wine bila diperlukan, dan terminal MT5.
- Linux/macOS memakai deteksi Wine/MT5; Windows memakai deteksi MT5 native. Wine tidak dipasang atau digunakan pada Windows native.
- Memisahkan **filesystem detection** dari **broker connection**. Menemukan `terminal64.exe` tidak berarti akun broker sudah login.
- Telegram menjadi control plane; state persisten disimpan di `~/.hermes/trading-mt5-state/`.
- Strategy lifecycle: IDEA -> HYPOTHESIS -> IMPLEMENTATION -> BACKTEST -> OUT-OF-SAMPLE -> DEMO/FORWARD -> CANDIDATE -> PROMOTED -> RETIRED.
- Evidence-based evolution: perubahan strategy harus didukung trade journal, eksperimen, test result, research, atau data lain yang tercatat.
- Cron supervisor hanya boleh mengelola job dengan marker `MT5-EVO-MANAGED:v1` dan nama `MT5-EVO-SUPERVISOR`.

## Requirements

### Wajib

- Hermes Agent terpasang dan command `hermes` tersedia untuk instalasi normal.
- Environment yang didukung oleh Hermes.
- Untuk trading MT5: terminal MT5 yang kompatibel dengan environment dan akses akun broker.
- Telegram Bot jika ingin menggunakan Telegram control plane.

### Linux / VPS

MT5 adalah aplikasi Windows. Pada Linux, project ini **mendeteksi Wine terlebih dahulu** dan kemudian mencari terminal MT5 di prefix Wine yang umum. Installer tidak menganggap Wine atau MT5 sudah ada hanya karena OS adalah Linux.

Jika Wine belum ada, installer hanya akan memasangnya ketika user secara eksplisit menjalankan opsi `--install-prereqs` dan menyetujui package-manager action. MT5 sendiri tidak diunduh secara diam-diam karena instalasi terminal/broker dapat berbeda.

### Windows

Installer mengenali Windows native ketika dijalankan dari shell yang menyediakan `powershell.exe` dan mencari `terminal64.exe`. Wine tidak diperlukan.

### macOS

Installer mencoba mendeteksi Wine dan terminal MT5 yang berada pada prefix Wine. Jika environment tidak menyediakan Wine/MT5, setup berhenti pada tahap diagnosis dan tidak mengarang status siap.

## Instalasi dari GitHub — cara yang direkomendasikan

Repository:

```text
https://github.com/Fannstores/hermes-trading-mt5
```

Hermes mendukung instalasi skill langsung dari GitHub dengan format `owner/repo/path-to-skill`. Struktur repo ini mengikuti standar tersebut: `skills/trading/trading-mt5/SKILL.md`.

### Opsi A — Install langsung sebagai Hermes skill

```bash
hermes skills install Fannstores/hermes-trading-mt5/skills/trading/trading-mt5
```

Lalu verifikasi:

```bash
hermes skills list | grep trading-mt5
```

Jika skill baru tidak muncul pada session yang sedang berjalan, mulai session Hermes baru atau reset session sesuai mekanisme Hermes. Skill terpasang berada di `~/.hermes/skills/`.

### Opsi B — Clone repository dan jalankan installer

```bash
git clone https://github.com/Fannstores/hermes-trading-mt5.git
cd hermes-trading-mt5
chmod +x install.sh
./install.sh
```

Installer akan melakukan:

```text
1. Validasi SKILL.md dan struktur repository
2. Deteksi OS + architecture
3. Deteksi Hermes CLI
4. Deteksi Python
5. Linux/macOS: deteksi Wine
6. Deteksi terminal MT5
7. Install/copy skill ke ~/.hermes/skills/trading/trading-mt5
8. Membuat persistent state directory
9. Menyimpan hasil preflight tanpa secret
10. Memverifikasi struktur skill
```

### Opsi C — Download ZIP

```text
GitHub -> Code -> Download ZIP
```

Extract ZIP, masuk ke folder repository, lalu jalankan:

```bash
chmod +x install.sh
./install.sh
```

Jangan menjalankan `SKILL.md` secara langsung. Skill dibaca oleh Hermes setelah dipasang ke `~/.hermes/skills/`.

## Preflight dan deteksi MT5

Installer **tidak langsung mengasumsikan MT5 tersedia**.

Contoh alur Linux:

```text
OS = Linux
  -> cari wine64/wine
  -> jika Wine ditemukan:
       cari terminal64.exe / terminal.exe
       di prefix Wine umum
  -> jika MT5 ditemukan:
       MT5 filesystem = FOUND
  -> jika tidak:
       MT5 filesystem = NOT FOUND
```

Contoh Windows:

```text
OS = Windows
  -> cari powershell.exe
  -> cari terminal64.exe pada lokasi Program Files/LocalAppData umum
  -> MT5 filesystem = FOUND / NOT FOUND
```

Hasil disimpan tanpa password/token di:

```text
~/.hermes/trading-mt5-state/environment.env
```

Untuk menjalankan pemeriksaan ulang setelah instalasi:

```bash
~/.hermes/skills/trading/trading-mt5/scripts/mt5_preflight.sh
```

**PASS filesystem tidak berarti broker login berhasil.** Hermes tetap harus melakukan discovery dan verification terhadap terminal, account, symbol, market data, dan bridge yang digunakan sebelum trading diizinkan.

## Prerequisite Linux opsional

Jika Linux belum memiliki dependency umum, installer dapat membantu memasang `curl`, `unzip`, `python3`, `git`, dan Wine melalui package manager yang didukung.

Gunakan hanya jika memang ingin installer melakukan package installation:

```bash
./install.sh --install-prereqs
```

Untuk mode non-interaktif yang sudah disetujui user:

```bash
./install.sh --install-prereqs --yes
```

Installer tidak mengunduh MT5 secara otomatis. Setelah Wine tersedia, terminal MT5 tetap harus tersedia di prefix yang dideteksi atau dipasang oleh user.


## Setup MetaTrader 5 sampai siap dipakai

Bagian ini adalah **wajib** sebelum Hermes boleh menganggap environment MT5 siap. Instalasi skill dan instalasi MetaTrader 5 adalah dua tahap berbeda. Dokumentasi ini mengikuti alur resmi MetaTrader 5 untuk instalasi platform dan login akun.

### 1. Pilih environment

| Environment | Cara MT5 | Wine |
|---|---|---|
| Windows native | Installer MT5 resmi Windows | Tidak |
| Linux VPS | Installer MT5 resmi untuk Linux | Ya, melalui Wine |
| macOS | Installer MT5 resmi macOS | Dikelola installer MetaTrader |
| WSL2 | Tidak direkomendasikan sebagai tempat menjalankan GUI MT5 kecuali environment GUI/Wine memang tersedia | Sesuai environment |

MetaTrader mendokumentasikan bahwa versi Linux berjalan menggunakan Wine dan menyediakan script resmi `mt5linux.sh` yang mendeteksi sistem, memasang Wine yang sesuai, lalu menjalankan installer MT5. Jika Wine meminta Mono/Gecko, komponen tersebut diperlukan untuk operasi platform. [Dokumentasi resmi MetaTrader 5 — Install on Linux](https://www.metatrader5.com/en/terminal/help/start_advanced/install_linux)

### 2. Linux/VPS — instal MT5 menggunakan metode resmi

Jika `mt5_preflight.sh` melaporkan `MT5: NOT FOUND`, jangan membuat prefix Wine secara acak. Untuk Ubuntu, Debian, Linux Mint, atau Fedora, gunakan installer Linux resmi MetaTrader:

```bash
wget https://download.terminal.free/cdn/web/metaquotes.software.corp/mt5/mt5linux.sh
chmod +x mt5linux.sh
./mt5linux.sh
```

Jalankan dari user biasa, **bukan `sudo ./mt5linux.sh`**. Installer resmi akan menangani Wine dan kemudian menjalankan installer MetaTrader. Jika muncul permintaan instalasi Wine Mono/Gecko, izinkan karena komponen tersebut diperlukan oleh platform. Setelah instalasi selesai, jalankan MT5 setidaknya sekali dan biarkan platform menyelesaikan update awal. 

Setelah itu jalankan ulang:

```bash
~/.hermes/skills/trading/trading-mt5/scripts/mt5_preflight.sh
```

Preflight harus menemukan executable MT5. **Executable ditemukan belum berarti akun broker sudah terhubung.**

### 3. Windows — instal MT5 resmi

Download dan jalankan installer MT5 resmi (`mt5setup.exe`), lalu ikuti wizard instalasi. MetaTrader mendokumentasikan Windows 10/11 sebagai platform yang didukung untuk terminal Windows. Installer dapat dipasang di lokasi standar atau lokasi custom. 

Setelah instalasi, buka MT5 secara manual satu kali. Jangan menghapus atau memindahkan folder instalasi setelah Hermes mendeteksinya tanpa menjalankan preflight ulang.

### 4. Buat atau siapkan akun MT5

Hermes **tidak membuat akun broker atau meminta password akun melalui Telegram**. Akun harus disiapkan di MT5/broker terlebih dahulu.

Ada dua jalur:

**A. Sudah punya akun broker**

Siapkan tiga data dari broker:

```text
Account/Login : nomor akun
Password      : master password atau investor password
Server        : nama server broker
```

Untuk koneksi yang dapat melakukan trading, gunakan **master password**. Investor password hanya memberikan akses untuk melihat status/analyze dan tidak dapat melakukan trading. 

**B. Belum punya akun**

Untuk tahap awal gunakan **demo account**. Di MT5 buka:

```text
File / Navigator
→ Open an Account
→ cari broker
→ pilih server
→ pilih/create demo account
```

MetaTrader menjelaskan bahwa demo account memakai dana virtual dan ditujukan untuk latihan/testing; real account melibatkan proses verifikasi broker. 

### 5. Login akun ke MT5

Di terminal MT5:

```text
File
→ Login to Trade Account
```

Isi:

```text
Login    = nomor akun
Password = password akun
Server   = server broker
```

Klik `OK`, lalu tunggu sampai terminal benar-benar terhubung. MetaTrader mendokumentasikan login dengan account number, password, dan server sebagai data utama koneksi. Opsi menyimpan password dapat digunakan agar terminal otomatis terhubung saat startup, sesuai kebutuhan environment server. citeturn1search5turn1search4

**Jangan mengirim tiga data tersebut ke Telegram.** Jika Hermes membutuhkan konfigurasi credential untuk adapter tertentu, gunakan mekanisme secret/config lokal yang disediakan environment, bukan chat.

### 6. Pastikan server broker benar

Kesalahan umum adalah menggunakan nama broker tetapi memilih server yang salah. Pastikan server yang dipilih sama persis dengan yang diberikan broker. Jika broker meminta alamat server custom, MetaTrader juga mendukung server address secara manual pada proses koneksi. 

### 7. Pastikan market data tersedia

Setelah login:

1. Buka `Market Watch`.
2. Cari symbol yang akan digunakan, misalnya `XAUUSD`.
3. Pastikan symbol tersedia pada broker/account tersebut.
4. Pastikan harga/bid/ask bergerak atau data tick tersedia.
5. Buka chart symbol jika perlu.
6. Jangan mengasumsikan nama symbol universal: broker dapat memakai suffix/prefix seperti `XAUUSDm`, `XAUUSD.a`, atau nama lain.

Hermes harus menggunakan symbol yang benar-benar ditemukan dari terminal/broker, bukan menebak nama symbol.

### 8. Pastikan terminal tetap hidup

Untuk environment VPS, MT5 harus tetap berjalan agar adapter yang bergantung pada terminal dapat berkomunikasi dengannya. Jangan menutup terminal setelah login. Untuk startup otomatis, gunakan service/supervisor yang sesuai setelah setup manual berhasil diverifikasi.

MetaTrader juga mendukung startup dengan parameter seperti `/login`, `/config`, `/profile`, dan `/portable`, tetapi konfigurasi otomatis harus dibuat hanya setelah akun/server dan path terminal sudah terverifikasi. 

### 9. Verification gate sebelum Hermes trading

Hermes harus melewati gate berikut secara berurutan:

```text
MT5 executable found
        ↓
Terminal starts
        ↓
Broker server reachable
        ↓
Account authenticated
        ↓
Account type detected (DEMO/REAL)
        ↓
Symbol discovered
        ↓
Bid/Ask or market data available
        ↓
Account balance/equity readable
        ↓
Trading permission verified
        ↓
Execution adapter verified
        ↓
READY
```

Status harus dibedakan:

```text
filesystem_found
terminal_ready
broker_authenticated
market_data_ready
execution_verified
```

`filesystem_found` **bukan** `READY`. Jika satu gate gagal, Hermes harus menunjukkan gate yang gagal dan root cause yang diketahui.

### 10. First-run checklist

Sebelum strategy atau autonomous trading:

```text
[ ] Hermes terinstall dan chat normal
[ ] trading-mt5 terinstall
[ ] OS/architecture terdeteksi
[ ] Wine terdeteksi jika Linux/macOS memerlukannya
[ ] MT5 executable ditemukan
[ ] MT5 bisa start
[ ] Broker/server benar
[ ] Account login berhasil
[ ] Account type diketahui: DEMO/REAL
[ ] Symbol target ditemukan
[ ] Market data tersedia
[ ] Balance/equity terbaca
[ ] Risk policy dikonfigurasi
[ ] Telegram Home Group terverifikasi jika Telegram dipakai
[ ] Mode tetap DEMO + MANUAL + READONLY selama validasi awal
```

Baru setelah checklist ini lolos Hermes boleh melanjutkan ke discovery strategy, backtest, forward test, atau execution sesuai permission.

### Referensi resmi MT5

- [Platform Installation](https://www.metatrader5.com/en/terminal/help/start_advanced/installation)
- [Installation on Linux](https://www.metatrader5.com/en/terminal/help/start_advanced/install_linux)
- [Open an Account](https://www.metatrader5.com/en/terminal/help/startworking/acc_open)
- [Connect to an Account](https://www.metatrader5.com/en/terminal/help/startworking/authorization)
- [Platform Settings — Server/Login](https://www.metatrader5.com/en/terminal/help/startworking/settings)
- [Platform Start / command-line parameters](https://www.metatrader5.com/en/terminal/help/start_advanced/start)

## Setelah install — jangan langsung trading

Urutan first run:

```text
Install skill
  -> Preflight
  -> Start/new Hermes session
  -> /status
  -> /mt5
  -> /account
  -> /broker
  -> /risk
  -> Telegram /sethome
  -> verify authorization
  -> verify MT5 login/data
  -> keep DEMO + READONLY + MANUAL
```

Jika salah satu komponen gagal, Hermes harus mendiagnosis root cause, memperbaiki hanya jika aman, lalu melakukan verification ulang. Jangan blind retry dan jangan menyatakan setup berhasil bila verification gagal.

## Telegram setup

1. Buat bot Telegram.
2. Simpan Bot Token sebagai secret; **jangan kirim token ke chat**.
3. Tambahkan bot ke Home Group.
4. Berikan permission admin hanya jika fitur yang digunakan memang membutuhkannya.
5. Pastikan privacy mode sesuai kebutuhan command grup.
6. Dari akun owner, kirim `/sethome` di Home Group.
7. Hermes memverifikasi Telegram User ID + Home Group ID + role.
8. Keanggotaan grup saja bukan permission operasi.
9. Unauthorized command tidak boleh membocorkan status internal.

Telegram hanya control plane. Telegram bukan database utama.

## Setup wajib: jangan menebak

Flow setup:

```text
PREFLIGHT -> DISCOVERY -> ASK ONE QUESTION -> WAIT -> APPLY -> VERIFY
```

Hermes tidak boleh menebak broker, account, symbol, risk, mode REAL, definisi 1R, atau izin autonomous. Jika informasi penting belum ada, Hermes bertanya dan **menunggu jawaban**.

## Troubleshooting instalasi

### `hermes: command not found`

Install Hermes terlebih dahulu, pastikan command `hermes` ada di PATH, lalu jalankan installer lagi atau gunakan instalasi skill langsung melalui Hermes.

### `MT5: NOT FOUND` di Linux

Periksa:

```bash
command -v wine64 || command -v wine
~/.hermes/skills/trading/trading-mt5/scripts/mt5_preflight.sh
```

Jika Wine ada tetapi MT5 tidak ditemukan, pasang terminal MT5 pada Wine prefix yang digunakan, lalu jalankan preflight ulang.

### `MT5: NOT FOUND` di Windows

Pastikan terminal MetaTrader 5 terpasang dan `terminal64.exe` berada pada lokasi yang dapat ditemukan. Jika berada di lokasi custom, gunakan discovery/konfigurasi Hermes untuk menetapkan path tersebut; jangan mengarang path.

### MT5 ditemukan tetapi broker belum login

Ini kondisi berbeda dari filesystem detection. Buka/siapkan terminal, login akun yang sesuai, pastikan symbol dan market data tersedia, kemudian minta Hermes melakukan verification lagi.

### Installer gagal

Jangan mengulang command yang sama secara buta. Baca output/error, identifikasi root cause, perbaiki komponen yang relevan, lalu jalankan preflight/verification ulang.

## Command utama

Semua command yang ditampilkan di `/helptrading` harus benar-benar terdaftar di command registry dan memiliki handler atau status `planned`. Command yang belum diimplementasikan tidak boleh dipromosikan sebagai aktif.

### Setup & control

| Command | Penjelasan |
|---|---|
| `/sethome` | Menetapkan grup Telegram sebagai Home Group Hermes. |
| `/status` | Melihat status Hermes, MT5, mode, strategy, dan trading gate. |
| `/starttrading` | Mengaktifkan kembali autonomous entry; tidak memaksa entry. |
| `/stoptreding` | Menghentikan entry autonomous baru tanpa menutup posisi terbuka. |
| `/stoptrading` | Alias `/stoptreding`. |
| `/pause` | Pause proses trading/evolution yang dapat dipause. |
| `/resume` | Melanjutkan proses yang dipause. |
| `/helptrading` | Menampilkan command trading dan panduan singkat Bahasa Indonesia. |

### Analisis & research

| Command | Penjelasan |
|---|---|
| `/analisis [SYMBOL]` | Analisis teknikal, fundamental, news, sesi, strategy, posisi, dan risiko. |
| `/analisisall` | Menganalisis semua symbol dalam watchlist. |
| `/signal [SYMBOL]` | Menampilkan signal dari strategy aktif beserta alasan dan data time. |
| `/research [TOPIC]` | Riset menggunakan sumber web yang relevan dan mencatat source/time. |
| `/news [SYMBOL]` | Mencari berita terbaru yang relevan. |
| `/calendar` | Melihat economic calendar yang tersedia. |
| `/sentiment [SYMBOL]` | Merangkum sentiment dari sumber yang tersedia tanpa menganggap sentiment sebagai kepastian. |
| `/watchlist` | Melihat symbol yang dipantau. |
| `/addwatch [SYMBOL]` | Menambahkan symbol ke watchlist. |
| `/delwatch [SYMBOL]` | Menghapus symbol dari watchlist. |

### Account, position & execution

| Command | Penjelasan |
|---|---|
| `/positions` | Melihat seluruh posisi aktif dari MT5. |
| `/position [TICKET]` | Melihat detail satu posisi. |
| `/orders` | Melihat pending orders. |
| `/history` | Melihat riwayat transaksi. |
| `/tradeinfo [TICKET]` | Melihat detail transaksi dan hasil verifikasi. |
| `/balance` | Melihat balance aktual. |
| `/equity` | Melihat equity aktual. |
| `/margin` | Melihat margin/free margin. |
| `/entry ...` | Membuka entry setelah permission, strategy, risk, dan broker checks lolos. |
| `/buy [SYMBOL]` | Shortcut BUY yang tetap melewati command/risk engine. |
| `/sell [SYMBOL]` | Shortcut SELL yang tetap melewati command/risk engine. |
| `/closeentry [SYMBOL]` | Menutup posisi symbol tertentu; jika ambigu, minta ticket. |
| `/close [TICKET]` | Menutup posisi berdasarkan ticket. |
| `/closeall` | Menutup semua posisi setelah konfirmasi eksplisit. |

Contoh:

```text
/entry XAUUSD BUY LOT 0.05 SL 1 TP 2
/entry XAUUSD BUY AUTOLOT RISK 1 SL 1 TP 2
```

`SL 1 TP 2` berarti **risk/reward 1R:2R**, bukan harga mentah. Definisi 1R harus berasal dari konfigurasi strategy, misalnya ATR, market structure, atau fixed distance. Jika belum ditentukan, Hermes harus bertanya.

### SL/TP & position management

| Command | Penjelasan |
|---|---|
| `/setsltp [SYMBOL] SL [R] TP [R]` | Menghitung dan memasang SL/TP dari definisi R strategy lalu memverifikasi hasilnya. |
| `/setsl [SYMBOL] SL [R]` | Mengubah SL berdasarkan R. |
| `/settp [SYMBOL] TP [R]` | Mengubah TP berdasarkan R. |
| `/trailsl [SYMBOL]` | Mengaktifkan/mengelola trailing stop sesuai policy strategy. |
| `/breakeven [SYMBOL]` | Memindahkan SL ke break-even jika syarat strategy terpenuhi. |
| `/partialclose [SYMBOL] [PERCENT]` | Menutup sebagian volume setelah validasi volume dan risk policy. |

### Risk

| Command | Penjelasan |
|---|---|
| `/risk` | Melihat seluruh risk policy aktif. |
| `/setrisk ...` | Mengubah risk policy setelah permission check. |
| `/maxlot [VALUE]` | Melihat/mengatur batas lot maksimum. |
| `/maxposition [VALUE]` | Melihat/mengatur jumlah posisi maksimum. |
| `/maxdrawdown [VALUE]` | Melihat/mengatur batas drawdown. |
| `/riskcheck [SYMBOL]` | Memeriksa apakah kondisi memenuhi risk gate. |
| `/dailyresult` | Melihat hasil trading harian. |
| `/drawdown` | Melihat drawdown saat ini. |

### Strategy & evolution

| Command | Penjelasan |
|---|---|
| `/strategies` | Menampilkan daftar strategy dan status lifecycle. |
| `/strateginew [INSTRUKSI]` | Membuat hipotesis/metode strategy baru dari instruksi natural language. |
| `/strategy info [NAME]` | Melihat aturan, versi, symbol, timeframe, risk, dan status strategy. |
| `/strategy use [NAME]` | Memilih strategy untuk mode yang diizinkan setelah validasi. |
| `/strategyimprove [NAME] [INSTRUKSI]` | Mengembangkan strategy berdasarkan evidence dan hasil eksperimen. |
| `/strategytest [NAME]` | Menjalankan test yang tersedia untuk strategy. |
| `/strategycompare [A] [B]` | Membandingkan metrics strategy tanpa mengarang data. |
| `/strategypromote [NAME]` | Memindahkan candidate ke status berikutnya hanya jika gate terpenuhi. |
| `/strategyretire [NAME]` | Menghentikan strategy dari penggunaan aktif. |
| `/strategyarchive [NAME]` | Mengarsipkan strategy tanpa menghapus history. |
| `/strategydelete [NAME]` | Menghapus strategy setelah confirmation dan safety checks. |
| `/strategyrollback [NAME] [VERSION]` | Mengembalikan strategy ke versi terdahulu. |
| `/backtest [NAME]` | Menjalankan backtest sesuai dataset/configuration. |
| `/backtestresult [NAME]` | Melihat hasil backtest terakhir. |
| `/forwardtest [NAME]` | Menjalankan/mengecek forward test atau demo validation. |
| `/experiment [NAME]` | Membuat eksperimen terkontrol dengan satu atau beberapa perubahan. |
| `/compare [EXPERIMENT_A] [EXPERIMENT_B]` | Membandingkan eksperimen. |
| `/evolution` | Melihat status evolution supervisor. |
| `/learn` | Membuat lesson dari evidence yang tersedia. |
| `/lessons` | Melihat lesson yang tersimpan. |

### Monitoring & automation

| Command | Penjelasan |
|---|---|
| `/report [today|week|month]` | Membuat laporan performa sesuai periode. |
| `/pnl` | Melihat PnL. |
| `/performance` | Melihat metrics performa strategy/account. |
| `/health` | Mengecek kesehatan MT5, bridge, Telegram, storage, dan worker. |
| `/logs` | Melihat log relevan tanpa membocorkan secret. |
| `/alerts` | Melihat alert aktif/terakhir. |
| `/mt5` | Melihat koneksi dan status MT5. |
| `/broker` | Melihat informasi broker yang tersedia. |
| `/account` | Melihat informasi akun tanpa secret. |
| `/cron` | Melihat managed cron. |
| `/tasks` | Melihat task evolution/research yang sedang berjalan. |

## Contoh `/strateginew`

### Contoh 1: SMC + SNR + Fibonacci

```text
/strateginew Coba buat metode baru menggunakan SMC + SNR + Fibonacci untuk XAUUSD. Gunakan H1 untuk bias dan M15 untuk entry. Research dulu, buat hipotesis, lalu backtest dan out-of-sample. Jangan gunakan REAL sebelum lolos validasi.
```

Hermes harus memperlakukan ini sebagai **hipotesis yang harus diuji**, bukan bukti bahwa metode tersebut profitable.

Flow:

```text
IDEA
 -> HYPOTHESIS
 -> IMPLEMENTATION
 -> BACKTEST
 -> OUT-OF-SAMPLE
 -> DEMO/FORWARD
 -> CANDIDATE
 -> PROMOTED
 -> RETIRED
```

### Contoh 2: strategy improvement

```text
/strategyimprove SMC-SNR-FIB-v1 Kurangi false entry saat market sideways. Gunakan evidence dari trade journal dan lakukan eksperimen terkontrol.
```

Hermes membuat **version baru**, bukan menimpa strategy aktif.

### Contoh 3: hapus strategy

```text
/strategydelete SMC-SNR-FIB-v1
```

Strategy aktif tidak boleh dihapus diam-diam. Hermes harus meminta confirmation, memastikan strategy tidak sedang dipakai, dan menyimpan archive/history bila policy retention mengharuskannya.

## Strategy versioning

Setiap perubahan harus menghasilkan versi baru, misalnya:

```text
SMC-SNR-FIB-v1
SMC-SNR-FIB-v2
SMC-SNR-FIB-v3
```

Minimal metadata:

- strategy id/name
- version
- status lifecycle
- symbols/timeframes
- entry rules
- exit rules
- filters
- definition of 1R
- risk assumptions
- dataset/time period
- backtest metrics
- OOS metrics
- forward/demo metrics
- change log
- evidence references
- created_at/updated_at

Jangan overwrite active strategy secara langsung.

## Autonomous trading

Tiga mode:

- `MANUAL`: user memerintah; semua command tetap divalidasi.
- `ASSISTED`: Hermes membuat proposal dan menunggu approval.
- `AUTONOMOUS`: Hermes dapat menjalankan action yang secara eksplisit diizinkan policy.

Izin REAL autonomous execution **harus menjadi setting eksplisit**. Jika belum dikonfirmasi, Hermes harus berhenti pada proposal/approval.

`/stoptreding` hanya mematikan **entry autonomous baru**. Posisi terbuka tidak otomatis ditutup.

## Execution pipeline

Semua jalan melalui jalur yang sama:

```text
Telegram / Autonomous Trigger
        -> parser
        -> command registry
        -> authentication/authorization
        -> validation
        -> strategy engine
        -> risk engine
        -> MT5 adapter
        -> verification/read-back
        -> journal
        -> Telegram result
```

Tidak boleh ada jalur autonomous yang melewati risk/validation hanya karena berasal dari cron.

## Risk guards

Minimal guard:

- max risk per trade
- max lot
- max positions
- daily loss limit
- max drawdown
- spread limit
- margin/free margin
- session/market condition
- stale/abnormal market data
- broker rejection/error rate
- duplicate order protection
- kill switch

Jika order gagal, jangan menyatakan sukses. Baca response broker, lakukan verification, lalu journal.

## Evolution supervisor

Managed cron wajib memakai nama:

```text
MT5-EVO-SUPERVISOR
```

dan marker:

```text
MT5-EVO-MANAGED:v1
```

Hermes hanya boleh membuat, memperbarui, atau menghapus cron yang memiliki marker tersebut. Cron user lain adalah out-of-scope.

Jika goal aktif berubah dan tidak lagi cocok dengan objective:

1. identifikasi managed cron lama;
2. hapus/update hanya cron dengan marker;
3. buat managed cron baru sesuai goal;
4. verifikasi schedule dan payload;
5. jangan menyentuh cron lain.

## Evidence-based learning

Hermes tidak boleh menyimpulkan strategy lebih baik hanya dari satu trade. Evidence dapat berasal dari:

- trade journal
- backtest
- OOS test
- forward/demo
- experiment
- market/fundamental research
- coding/test result
- broker/execution errors

Lesson harus memiliki evidence, confidence/limitations, dan action yang diusulkan. Perubahan strategy harus melalui versioning.

## Persistent state

Contoh struktur:

```text
state/
├── setup.json
├── goals.json
├── experiments.json
├── lessons.json
├── watchlist.json
├── risk.json
├── strategies/
│   ├── SMC-SNR-FIB-v1.json
│   └── ...
├── trades/
├── research/
└── cron/
```

Telegram bukan database utama.

## Security

- Jangan meminta atau mencetak broker password di Telegram.
- Jangan menyimpan secret di Git.
- Jangan memasukkan token API ke strategy notes.
- Authorization berdasarkan Telegram User ID + Home Group + role.
- IP allowlist boleh menjadi lapisan tambahan untuk server/API, bukan pengganti identity Telegram.
- Sensitive commands harus melalui authorization dan audit journal.

## Disclaimer

Trading mengandung risiko kehilangan modal. Skill ini adalah automation/research tooling, bukan nasihat keuangan dan tidak menjamin profit.
