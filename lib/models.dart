double _d(dynamic v) => v == null ? 0.0 : (v as num).toDouble();
double? _dn(dynamic v) => v == null ? null : (v as num).toDouble();
DateTime? _dt(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

class Position {
  Position({
    required this.ticket,
    required this.symbol,
    required this.type,
    required this.volume,
    required this.priceOpen,
    required this.priceCurrent,
    required this.sl,
    required this.tp,
    required this.profit,
    required this.swap,
    required this.time,
    required this.comment,
  });

  final int ticket;
  final String symbol;
  final String type;
  final double volume;
  final double priceOpen;
  final double priceCurrent;
  final double sl;
  final double tp;
  final double profit;
  final double swap;
  final int time;
  final String comment;

  factory Position.fromJson(Map<String, dynamic> j) => Position(
        ticket: (j['ticket'] as num?)?.toInt() ?? 0,
        symbol: (j['symbol'] ?? '').toString(),
        type: (j['type'] ?? '').toString(),
        volume: _d(j['volume']),
        priceOpen: _d(j['price_open']),
        priceCurrent: _d(j['price_current']),
        sl: _d(j['sl']),
        tp: _d(j['tp']),
        profit: _d(j['profit']),
        swap: _d(j['swap']),
        time: (j['time'] as num?)?.toInt() ?? 0,
        comment: (j['comment'] ?? '').toString(),
      );
}

class LotSizer {
  LotSizer({
    required this.halved,
    required this.winsAfterHalve,
    required this.recentPnlsCount,
    required this.lastPnl,
  });

  final bool halved;
  final int winsAfterHalve;
  final int recentPnlsCount;
  final double? lastPnl;

  factory LotSizer.fromJson(Map<String, dynamic> j) => LotSizer(
        halved: j['halved'] == true,
        winsAfterHalve: (j['wins_after_halve'] as num?)?.toInt() ?? 0,
        recentPnlsCount: (j['recent_pnls_count'] as num?)?.toInt() ?? 0,
        lastPnl: _dn(j['last_pnl']),
      );
}

class BotStatus {
  BotStatus({
    required this.balance,
    required this.equity,
    required this.margin,
    required this.freeMargin,
    required this.server,
    required this.currency,
    required this.connected,
    required this.stopped,
    required this.magic,
    required this.pollInterval,
    required this.positions,
    required this.lotSizer,
    required this.telegramEnabled,
    required this.telegramDegraded,
  });

  final double balance;
  final double equity;
  final double margin;
  final double freeMargin;
  final String server;
  final String currency;
  final bool connected;
  final bool stopped;
  final int magic;
  final int pollInterval;
  final List<Position> positions;
  final LotSizer? lotSizer;
  final bool telegramEnabled;
  final bool telegramDegraded;

  double get openPnl => equity - balance;

  factory BotStatus.fromJson(Map<String, dynamic> j) => BotStatus(
        balance: _d(j['balance']),
        equity: _d(j['equity']),
        margin: _d(j['margin']),
        freeMargin: _d(j['free_margin']),
        server: (j['server'] ?? '').toString(),
        currency: (j['currency'] ?? '').toString(),
        connected: j['connected'] == true,
        stopped: j['stopped'] == true,
        magic: (j['magic'] as num?)?.toInt() ?? 0,
        pollInterval: (j['poll_interval'] as num?)?.toInt() ?? 0,
        positions: ((j['open_positions'] as List?) ?? const [])
            .map((e) => Position.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        lotSizer: j['lot_sizer'] is Map
            ? LotSizer.fromJson(Map<String, dynamic>.from(j['lot_sizer'] as Map))
            : null,
        telegramEnabled: j['telegram_enabled'] == true,
        telegramDegraded: j['telegram_degraded'] == true,
      );
}

class Summary {
  Summary({
    required this.tradesClosed,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.totalPnl,
    required this.bestTrade,
    required this.worstTrade,
  });

  final int tradesClosed;
  final int wins;
  final int losses;
  final double winRate;
  final double totalPnl;
  final double bestTrade;
  final double worstTrade;

  factory Summary.fromJson(Map<String, dynamic> j) => Summary(
        tradesClosed: (j['trades_closed'] as num?)?.toInt() ?? 0,
        wins: (j['wins'] as num?)?.toInt() ?? 0,
        losses: (j['losses'] as num?)?.toInt() ?? 0,
        winRate: _d(j['win_rate']),
        totalPnl: _d(j['total_pnl']),
        bestTrade: _d(j['best_trade']),
        worstTrade: _d(j['worst_trade']),
      );
}

class Trade {
  Trade({
    required this.ticket,
    required this.symbol,
    required this.side,
    required this.lot,
    required this.entryPrice,
    required this.closePrice,
    required this.pnl,
    required this.openedAt,
    required this.closedAt,
    required this.strategy,
    required this.comment,
  });

  final int ticket;
  final String symbol;
  final String side;
  final double lot;
  final double entryPrice;
  final double? closePrice;
  final double? pnl;
  final DateTime? openedAt;
  final DateTime? closedAt;
  final String strategy;
  final String comment;

  bool get isOpen => pnl == null;

  factory Trade.fromJson(Map<String, dynamic> j) => Trade(
        ticket: (j['ticket'] as num?)?.toInt() ?? 0,
        symbol: (j['symbol'] ?? '').toString(),
        side: (j['side'] ?? '').toString(),
        lot: _d(j['lot']),
        entryPrice: _d(j['entry_price']),
        closePrice: _dn(j['close_price']),
        pnl: _dn(j['pnl']),
        openedAt: _dt(j['opened_at']),
        closedAt: _dt(j['closed_at']),
        strategy: (j['strategy'] ?? '').toString(),
        comment: (j['comment'] ?? '').toString(),
      );
}

class SignalRow {
  SignalRow({
    required this.dt,
    required this.symbol,
    required this.action,
    required this.strength,
    required this.h1Rsi,
    required this.executed,
    required this.rejectReason,
  });

  final DateTime? dt;
  final String symbol;
  final String? action;
  final double strength;
  final double h1Rsi;
  final bool executed;
  final String rejectReason;

  factory SignalRow.fromJson(Map<String, dynamic> j) => SignalRow(
        dt: _dt(j['dt']),
        symbol: (j['symbol'] ?? '').toString(),
        action: j['action']?.toString(),
        strength: _d(j['strength']),
        h1Rsi: _d(j['h1_rsi']),
        executed: j['executed'] == true,
        rejectReason: (j['reject_reason'] ?? '').toString(),
      );
}

class BreakerConfig {
  BreakerConfig({
    required this.dailyDdPct,
    required this.maxLossStreak,
    required this.rejectRatePct,
  });

  final double dailyDdPct;
  final int maxLossStreak;
  final double rejectRatePct;

  factory BreakerConfig.fromJson(Map<String, dynamic> j) => BreakerConfig(
        dailyDdPct: _d(j['daily_dd_pct']),
        maxLossStreak: (j['max_loss_streak'] as num?)?.toInt() ?? 0,
        rejectRatePct: _d(j['reject_rate_pct']),
      );
}

class CircuitBreaker {
  CircuitBreaker({
    required this.enabled,
    required this.tripped,
    required this.reason,
    required this.lossStreak,
    required this.dailyAnchorBalance,
    required this.config,
  });

  final bool enabled;
  final bool tripped;
  final String reason;
  final int lossStreak;
  final double dailyAnchorBalance;
  final BreakerConfig? config;

  factory CircuitBreaker.fromJson(Map<String, dynamic> j) => CircuitBreaker(
        enabled: j['enabled'] == true,
        tripped: j['tripped'] == true,
        reason: (j['reason'] ?? '').toString(),
        lossStreak: (j['loss_streak'] as num?)?.toInt() ?? 0,
        dailyAnchorBalance: _d(j['daily_anchor_balance']),
        config: j['config'] is Map
            ? BreakerConfig.fromJson(Map<String, dynamic>.from(j['config'] as Map))
            : null,
      );
}

class LicenseInfo {
  LicenseInfo({
    required this.enabled,
    required this.userId,
    required this.daysLeft,
    required this.state,
  });

  final bool enabled;
  final String userId;
  final int daysLeft;
  final String state;

  factory LicenseInfo.fromJson(Map<String, dynamic> j) => LicenseInfo(
        enabled: j['enabled'] == true,
        userId: (j['user_id'] ?? '').toString(),
        daysLeft: (j['days_left'] as num?)?.toInt() ?? 0,
        state: (j['state'] ?? '').toString(),
      );
}
