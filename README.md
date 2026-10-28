# mt5-bot-monitor-flutter

Flutter client (Android / iOS / web, one codebase) for watching an MT5 bot that runs behind a Python bridge. It talks to the same REST API as the web dashboard, and the demo data comes from the PandaFX3 demo server.

## Screens

- **Overview**: balance, equity, open P/L, position count, rolling stats, risk guard (circuit breaker), equity curve and license chip.
- **Positions**: one card per open position with side, lots, entry to current price, SL / TP, P/L and swap.
- **Trades**: recent closed and open trades with win/loss counts, P/L and status chips.
- **Signals**: recent signals with action, strength bar, H1 RSI and execution result (exec / skip / no-sig).
- **Settings**: base URL (saved locally), refresh interval slider (3-30 s) and about text.

## API contract

All endpoints are `GET` and return JSON.

| Endpoint | Fields used |
|---|---|
| `/api/status` | balance, equity, margin, free_margin, server, currency, connected, stopped, magic, poll_interval, open_positions (ticket, symbol, type, volume, price_open, price_current, sl, tp, profit, swap, time, comment), lot_sizer, telegram_enabled, telegram_degraded |
| `/api/summary` | trades_closed, wins, losses, win_rate, total_pnl, best_trade, worst_trade |
| `/api/trades?limit=30` | ticket, symbol, side, lot, entry_price, close_price, pnl (null = open), opened_at, closed_at, strategy, comment |
| `/api/signals?limit=50` | dt, symbol, action, strength, h1_rsi, executed, reject_reason |
| `/api/circuit-breaker` | enabled, tripped, reason, loss_streak, daily_anchor_balance, config (daily_dd_pct, max_loss_streak, reject_rate_pct) |
| `/api/license` | enabled, user_id, days_left, state |

## Run against the demo server

1. Start the demo server from the `pandafx3-demo` folder: `python demo_dashboard.py` (port 5581, no MT5 and no trading).
2. Run the app in Chrome: `flutter run -d chrome`.

The base URL is taken from the page origin on web. On other platforms it defaults to `http://127.0.0.1:5581` and can be changed in Settings.

To serve the web build from the demo server under `/mobile/`:

1. `flutter build web --release --base-href /mobile/`
2. Mount `build/web` at `/mobile` in the FastAPI app, then open `http://127.0.0.1:5581/mobile/`.

## Build for devices

- Android: `flutter build apk --release` (requires the Android SDK).
- iOS: `flutter build ios --release` (requires Xcode).

## Tests

- `flutter analyze`
- `flutter test` (widget test with a fake API client)

## Limitations

- Polling, not websockets: the app refreshes on a timer and on pull-to-refresh.
- No auth in the demo API. For production, add a bearer token header in `ApiClient`.
- All numbers shown with the demo server are demo data.

## License

MIT
