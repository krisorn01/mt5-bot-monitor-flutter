import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'models.dart';

/// Holds the latest data from the bridge API and notifies listeners.
class BotRepository extends ChangeNotifier {
  BotRepository(this.api);

  final ApiClient api;

  BotStatus? status;
  Summary? summary;
  List<Trade> trades = const [];
  List<SignalRow> signals = const [];
  CircuitBreaker? breaker;
  LicenseInfo? license;
  DateTime? updatedAt;
  String? error;
  bool loading = false;
  int refreshSeconds = 5;

  static const _kUrl = 'base_url';
  static const _kInterval = 'refresh_s';

  Future<void> loadPrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      final u = p.getString(_kUrl);
      if (u != null && u.isNotEmpty) api.baseUrl = u;
      refreshSeconds = (p.getInt(_kInterval) ?? 5).clamp(3, 30);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> savePrefs({String? baseUrl, int? seconds}) async {
    if (baseUrl != null) api.baseUrl = baseUrl.trim();
    if (seconds != null) refreshSeconds = seconds.clamp(3, 30);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kUrl, api.baseUrl);
      await p.setInt(_kInterval, refreshSeconds);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> refresh() async {
    if (loading) return;
    loading = true;
    try {
      final r = await Future.wait<dynamic>([
        api.status(),
        api.summary(),
        api.trades(limit: 30),
        api.signals(limit: 50),
        api.circuitBreaker(),
        api.license(),
      ]);
      status = r[0] as BotStatus;
      summary = r[1] as Summary;
      trades = r[2] as List<Trade>;
      signals = r[3] as List<SignalRow>;
      breaker = r[4] as CircuitBreaker;
      license = r[5] as LicenseInfo;
      updatedAt = DateTime.now();
      error = null;
    } catch (_) {
      error = 'Cannot reach ${api.baseUrl}';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Closed trades, oldest first (for the equity curve).
  List<Trade> get closedOldestFirst {
    final c = trades.where((t) => t.pnl != null).toList();
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    c.sort((a, b) => (a.closedAt ?? a.openedAt ?? epoch)
        .compareTo(b.closedAt ?? b.openedAt ?? epoch));
    return c;
  }
}

class RepositoryScope extends InheritedNotifier<BotRepository> {
  const RepositoryScope({super.key, required BotRepository repo, required super.child})
      : super(notifier: repo);

  static BotRepository of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<RepositoryScope>();
    assert(s != null, 'RepositoryScope missing');
    return s!.notifier!;
  }
}
