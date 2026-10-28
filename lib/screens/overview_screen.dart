import 'package:flutter/material.dart';

import '../repository.dart';
import '../theme.dart';
import '../widgets.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = RepositoryScope.of(context);
    final st = repo.status;
    final sm = repo.summary;
    final cb = repo.breaker;
    final lic = repo.license;

    if (st == null && repo.error == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final openPnl = st?.openPnl ?? 0.0;
    return RefreshList(
      onRefresh: repo.refresh,
      children: [
        if (st != null) ...[
          Row(children: [
            Expanded(child: _Kpi('Balance', money(st.balance), kText)),
            const SizedBox(width: 10),
            Expanded(child: _Kpi('Equity', money(st.equity), kText)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _Kpi('Open P/L', signed(openPnl), pnlColor(openPnl))),
            const SizedBox(width: 10),
            Expanded(child: _Kpi('Positions', '${st.positions.length}', kBlue)),
          ]),
          const SizedBox(height: 10),
        ],
        if (lic != null && lic.enabled) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: StatusChip(
              lic.state == 'ok'
                  ? 'License OK · ${lic.daysLeft} days'
                  : 'License ${lic.state} · ${lic.daysLeft} days',
              lic.state == 'ok' ? kGreen : kAmber,
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (sm != null) ...[
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionTitle('Rolling stats'),
              KeyValueRow('Trades closed', '${sm.tradesClosed}'),
              KeyValueRow('Win rate', '${sm.winRate.toStringAsFixed(1)}%'),
              KeyValueRow('Total P/L', signed(sm.totalPnl), valueColor: pnlColor(sm.totalPnl)),
              KeyValueRow('Best trade', signed(sm.bestTrade), valueColor: pnlColor(sm.bestTrade)),
              KeyValueRow('Worst trade', signed(sm.worstTrade), valueColor: pnlColor(sm.worstTrade)),
            ]),
          ),
          const SizedBox(height: 10),
        ],
        if (cb != null) ...[
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle('Risk guard'),
                  if (!cb.enabled)
                    const StatusChip('off', kMuted)
                  else
                    StatusChip(cb.tripped ? 'TRIPPED' : 'armed', cb.tripped ? kRed : kGreen),
                ],
              ),
              KeyValueRow('Loss streak',
                  '${cb.lossStreak} / ${cb.config?.maxLossStreak ?? 0}'),
              KeyValueRow('Daily DD limit',
                  '${(cb.config?.dailyDdPct ?? 0).toStringAsFixed(0)}%'),
              KeyValueRow('Day-start balance', money(cb.dailyAnchorBalance)),
            ]),
          ),
          const SizedBox(height: 10),
        ],
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionTitle('Equity curve (last 30 closed trades)'),
            SizedBox(
              height: 120,
              child: CustomPaint(
                size: Size.infinite,
                painter: EquityCurvePainter(
                  repo.closedOldestFirst.map((t) => t.pnl ?? 0.0).toList(),
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: kMuted, fontSize: 12)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
          ),
        ]),
      );
}

/// Cumulative-pnl line, drawn without any chart package.
class EquityCurvePainter extends CustomPainter {
  EquityCurvePainter(this.pnls);
  final List<double> pnls;

  @override
  void paint(Canvas canvas, Size size) {
    if (pnls.isEmpty) return;
    final pts = <double>[0];
    var acc = 0.0;
    for (final p in pnls) {
      acc += p;
      pts.add(acc);
    }
    var lo = pts.reduce((a, b) => a < b ? a : b);
    var hi = pts.reduce((a, b) => a > b ? a : b);
    if (hi - lo < 1e-9) {
      hi += 1;
      lo -= 1;
    }
    final pad = (hi - lo) * 0.08;
    lo -= pad;
    hi += pad;
    double x(int i) => size.width * i / (pts.length - 1);
    double y(double v) => size.height - (v - lo) / (hi - lo) * size.height;

    final zero = Paint()
      ..color = kOutline
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, y(0)), Offset(size.width, y(0)), zero);

    final path = Path()..moveTo(x(0), y(pts[0]));
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(x(i), y(pts[i]));
    }
    final color = pts.last >= 0 ? kGreen : kRed;

    final fill = Path.from(path)
      ..lineTo(x(pts.length - 1), y(0))
      ..lineTo(x(0), y(0))
      ..close();
    canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.12));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant EquityCurvePainter old) => old.pnls != pnls;
}
