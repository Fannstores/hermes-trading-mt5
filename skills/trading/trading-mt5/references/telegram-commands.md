# Telegram Commands — Bahasa Indonesia

Gunakan registry ini sebagai source of truth. Jangan menampilkan command yang tidak mempunyai implementation status yang sesuai.

## Setup/control

- `/sethome` — menetapkan Home Group.
- `/status` — melihat status sistem/trading.
- `/starttrading` — mengaktifkan autonomous entry.
- `/stoptreding` — menghentikan autonomous entry baru.
- `/stoptrading` — alias stop.
- `/pause` — pause proses yang bisa dipause.
- `/resume` — melanjutkan proses.
- `/helptrading` — menampilkan bantuan command.

## Strategy

- `/strategies` — daftar strategy.
- `/strateginew ...` — membuat hypothesis/metode baru.
- `/strategy info NAME` — detail strategy.
- `/strategy use NAME` — memilih strategy.
- `/strategyimprove NAME ...` — membuat improvement version.
- `/strategytest NAME` — menjalankan test.
- `/strategycompare A B` — membandingkan strategy.
- `/strategypromote NAME` — promote jika gate terpenuhi.
- `/strategyretire NAME` — retire strategy.
- `/strategyarchive NAME` — archive tanpa kehilangan history.
- `/strategydelete NAME` — delete dengan confirmation/safety checks.
- `/strategyrollback NAME VERSION` — rollback version.

## Trading

- `/analisis SYMBOL` — analisis lengkap.
- `/signal SYMBOL` — signal strategy.
- `/entry SYMBOL BUY|SELL LOT x SL 1 TP 2` — entry manual tervalidasi.
- `/entry SYMBOL BUY|SELL AUTOLOT RISK 1 SL 1 TP 2` — entry dengan auto lot.
- `/buy SYMBOL` — shortcut BUY.
- `/sell SYMBOL` — shortcut SELL.
- `/closeentry SYMBOL` — close posisi symbol; minta ticket jika ambigu.
- `/close TICKET` — close ticket.
- `/closeall` — close semua setelah confirmation.

## Position management

- `/positions` — posisi aktif.
- `/position TICKET` — detail posisi.
- `/orders` — pending orders.
- `/history` — history.
- `/tradeinfo TICKET` — detail transaction.
- `/setsltp SYMBOL SL 1 TP 2` — set SL/TP dari R.
- `/setsl SYMBOL SL 1` — set SL.
- `/settp SYMBOL TP 2` — set TP.
- `/trailsl SYMBOL` — trailing stop.
- `/breakeven SYMBOL` — break-even.
- `/partialclose SYMBOL 50` — partial close 50%.

## Risk/account/monitoring

- `/risk` — risk policy.
- `/setrisk ...` — update risk policy.
- `/maxlot VALUE` — max lot.
- `/maxposition VALUE` — max positions.
- `/maxdrawdown VALUE` — max DD.
- `/riskcheck SYMBOL` — risk gate.
- `/dailyresult` — daily result.
- `/drawdown` — current DD.
- `/balance` — balance.
- `/equity` — equity.
- `/margin` — margin.
- `/report` — report.
- `/pnl` — PnL.
- `/performance` — performance.
- `/health` — system health.
- `/logs` — relevant logs.
- `/alerts` — alerts.
- `/mt5` — MT5 state.
- `/broker` — broker information.
- `/account` — account information.

## Research/watchlist

- `/research TOPIC` — web research.
- `/news SYMBOL` — news.
- `/calendar` — economic calendar.
- `/sentiment SYMBOL` — sentiment summary.
- `/watchlist` — watchlist.
- `/addwatch SYMBOL` — add symbol.
- `/delwatch SYMBOL` — remove symbol.

## Evolution/automation

- `/backtest NAME` — backtest.
- `/backtestresult NAME` — result.
- `/forwardtest NAME` — forward/demo test.
- `/experiment NAME` — experiment.
- `/compare A B` — compare experiments.
- `/evolution` — evolution state.
- `/learn` — derive lesson from evidence.
- `/lessons` — stored lessons.
- `/goal` — goal state.
- `/cron` — managed cron.
- `/tasks` — tasks.

### Help categories

`/helptrading entry`, `/helptrading risk`, `/helptrading strategy`, `/helptrading analysis`, `/helptrading system`

Descriptions must remain short enough for Telegram but link to this detailed reference when needed.
