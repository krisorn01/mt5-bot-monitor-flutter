import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'api_client.dart';
import 'repository.dart';
import 'screens/overview_screen.dart';
import 'screens/positions_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signals_screen.dart';
import 'screens/trades_screen.dart';
import 'theme.dart';
import 'widgets.dart';

void main() {
  runApp(MonitorApp(repository: BotRepository(ApiClient())));
}

GoRouter buildRouter() => GoRouter(
      initialLocation: '/overview',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => HomeShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: '/overview', builder: (c, s) => const OverviewScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/positions', builder: (c, s) => const PositionsScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/trades', builder: (c, s) => const TradesScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/signals', builder: (c, s) => const SignalsScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
            ]),
          ],
        ),
      ],
    );

class MonitorApp extends StatefulWidget {
  const MonitorApp({super.key, required this.repository});
  final BotRepository repository;

  @override
  State<MonitorApp> createState() => _MonitorAppState();
}

class _MonitorAppState extends State<MonitorApp> {
  late final GoRouter _router = buildRouter();
  Timer? _timer;
  int _timerSeconds = 0;

  @override
  void initState() {
    super.initState();
    widget.repository.addListener(_syncTimer);
    widget.repository.loadPrefs().then((_) {
      widget.repository.refresh();
    });
    _syncTimer();
  }

  void _syncTimer() {
    final s = widget.repository.refreshSeconds;
    if (_timer != null && _timerSeconds == s) return;
    _timer?.cancel();
    _timerSeconds = s;
    _timer = Timer.periodic(Duration(seconds: s), (_) => widget.repository.refresh());
  }

  @override
  void dispose() {
    widget.repository.removeListener(_syncTimer);
    _timer?.cancel();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryScope(
      repo: widget.repository,
      child: MaterialApp.router(
        title: 'MT5 Bot Monitor',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        themeMode: ThemeMode.dark,
        darkTheme: buildTheme(),
        routerConfig: _router,
      ),
    );
  }
}

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final repo = RepositoryScope.of(context);
    final st = repo.status;
    final String pill;
    final Color pillColor;
    if (st == null || !st.connected) {
      pill = 'no MT5';
      pillColor = kRed;
    } else if (st.stopped) {
      pill = 'stopped';
      pillColor = kAmber;
    } else {
      pill = 'running';
      pillColor = kGreen;
    }
    final updated = repo.updatedAt == null
        ? 'updated --:--:--'
        : 'updated ${DateFormat('HH:mm:ss').format(repo.updatedAt!)}';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MT5 Bot Monitor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(updated, style: const TextStyle(fontSize: 11, color: kMuted)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: StatusChip(pill, pillColor)),
          ),
        ],
      ),
      body: Column(
        children: [
          if (repo.error != null)
            Container(
              width: double.infinity,
              color: kRed.withValues(alpha: 0.85),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Text(repo.error!,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          Expanded(child: shell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Positions'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Trades'),
          NavigationDestination(icon: Icon(Icons.bolt), label: 'Signals'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
