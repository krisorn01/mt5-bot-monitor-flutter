import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mt5_bot_monitor/api_client.dart';
import 'package:mt5_bot_monitor/main.dart';
import 'package:mt5_bot_monitor/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeApiClient extends ApiClient {
  FakeApiClient() : super(baseUrl: 'http://fake');

  @override
  Future<dynamic> getJson(String path) async {
    if (path.startsWith('/api/status')) {
      return {
        'balance': 5236.40,
        'equity': 5240.57,
        'margin': 64.20,
        'free_margin': 5176.37,
        'server': 'Demo',
        'currency': 'USD',
        'connected': true,
        'stopped': false,
        'magic': 330011,
        'poll_interval': 30,
        'open_positions': [
          {
            'ticket': 1,
            'symbol': 'EURUSDc',
            'type': 'BUY',
            'volume': 0.03,
            'price_open': 1.16412,
            'price_current': 1.16480,
            'sl': 1.16180,
            'tp': 1.16880,
            'profit': 2.04,
            'swap': -0.12,
            'time': 1793189705,
            'comment': 'PFX3 ml',
          },
          {
            'ticket': 2,
            'symbol': 'USDJPYc',
            'type': 'SELL',
            'volume': 0.02,
            'price_open': 153.284,
            'price_current': 153.112,
            'sl': 153.620,
            'tp': 152.610,
            'profit': 2.25,
            'swap': 0.0,
            'time': 1793195045,
            'comment': 'PFX3 ml',
          },
        ],
        'lot_sizer': {
          'halved': false,
          'wins_after_halve': 0,
          'recent_pnls_count': 27,
          'last_pnl': 3.84,
        },
        'telegram_enabled': true,
        'telegram_degraded': false,
      };
    }
    if (path.startsWith('/api/summary')) {
      return {
        'trades_closed': 142,
        'wins': 79,
        'losses': 63,
        'win_rate': 55.6,
        'total_pnl': 236.40,
        'best_trade': 18.92,
        'worst_trade': -11.40,
      };
    }
    if (path.startsWith('/api/trades')) {
      return [
        {
          'ticket': 10,
          'symbol': 'GBPUSDc',
          'side': 'BUY',
          'lot': 0.02,
          'entry_price': 1.31,
          'close_price': 1.312,
          'pnl': 4.5,
          'opened_at': '2026-10-28T10:00:00',
          'closed_at': '2026-10-28T12:00:00',
          'strategy': 'ml',
          'comment': 'PFX3',
        },
        {
          'ticket': 11,
          'symbol': 'AUDUSDc',
          'side': 'SELL',
          'lot': 0.01,
          'entry_price': 0.65,
          'close_price': 0.651,
          'pnl': -1.2,
          'opened_at': '2026-10-28T08:00:00',
          'closed_at': '2026-10-28T09:00:00',
          'strategy': 'ml',
          'comment': 'PFX3',
        },
        {
          'ticket': 12,
          'symbol': 'EURUSDc',
          'side': 'BUY',
          'lot': 0.03,
          'entry_price': 1.16412,
          'close_price': null,
          'pnl': null,
          'opened_at': '2026-10-28T12:15:05',
          'closed_at': null,
          'strategy': 'ml',
          'comment': 'PFX3',
        },
      ];
    }
    if (path.startsWith('/api/signals')) {
      return [
        {
          'dt': '2026-10-28T14:14:03',
          'symbol': 'NZDUSDc',
          'action': null,
          'strength': 0.41,
          'h1_rsi': 37.1,
          'executed': false,
          'reject_reason': '',
        },
        {
          'dt': '2026-10-28T13:44:03',
          'symbol': 'USDJPYc',
          'action': 'SELL',
          'strength': 0.64,
          'h1_rsi': 71.6,
          'executed': true,
          'reject_reason': '',
        },
      ];
    }
    if (path.startsWith('/api/circuit-breaker')) {
      return {
        'enabled': true,
        'tripped': false,
        'reason': 'none',
        'loss_streak': 1,
        'daily_anchor_balance': 5232.10,
        'config': {'daily_dd_pct': 5.0, 'max_loss_streak': 6, 'reject_rate_pct': 50},
      };
    }
    if (path.startsWith('/api/license')) {
      return {'enabled': true, 'user_id': 'demo', 'days_left': 260, 'state': 'ok'};
    }
    throw Exception('unexpected path $path');
  }
}

void main() {
  testWidgets('Overview and Positions show fixed API data', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final repo = BotRepository(FakeApiClient());
    await tester.pumpWidget(MonitorApp(repository: repo));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('MT5 Bot Monitor'), findsOneWidget);
    expect(find.text('5,236.40'), findsOneWidget);
    expect(find.text('55.6%'), findsOneWidget);
    expect(find.text('running'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.list_alt));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('EURUSDc'), findsOneWidget);
    expect(find.text('USDJPYc'), findsOneWidget);

    // Dispose the app so the periodic refresh timer is cancelled.
    await tester.pumpWidget(const SizedBox());
  });
}
