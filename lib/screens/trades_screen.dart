import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models.dart';
import '../repository.dart';
import '../theme.dart';
import '../widgets.dart';

final DateFormat _fmt = DateFormat('HH:mm dd/MM');

class TradesScreen extends StatelessWidget {
  const TradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = RepositoryScope.of(context);
    if (repo.status == null && repo.error == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final sm = repo.summary;
    final trades = repo.trades;
    return RefreshList(
      onRefresh: repo.refresh,
      children: [
        if (sm != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              StatusChip('${sm.wins} wins', kGreen),
              const SizedBox(width: 8),
              StatusChip('${sm.losses} losses', kRed),
              const Spacer(),
              Text('last ${trades.length} trades',
                  style: const TextStyle(color: kMuted, fontSize: 12)),
            ]),
          ),
        if (trades.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(child: Text('No trades yet', style: TextStyle(color: kMuted))),
          ),
        for (final t in trades) ...[
          _TradeRow(t),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _TradeRow extends StatelessWidget {
  const _TradeRow(this.t);
  final Trade t;

  @override
  Widget build(BuildContext context) {
    final when = t.closedAt ?? t.openedAt;
    final pnl = t.pnl;
    final String status;
    final Color statusColor;
    if (pnl == null) {
      status = 'open';
      statusColor = kBlue;
    } else if (pnl > 0) {
      status = 'win';
      statusColor = kGreen;
    } else {
      status = 'loss';
      statusColor = kRed;
    }
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(t.symbol, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              StatusChip(t.side, sideColor(t.side)),
            ]),
            const SizedBox(height: 4),
            Text(
              '${when == null ? '-' : _fmt.format(when)}  ·  ${t.lot.toStringAsFixed(2)} lot',
              style: const TextStyle(color: kMuted, fontSize: 12),
            ),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(pnl == null ? '-' : signed(pnl),
              style: TextStyle(
                  color: pnl == null ? kMuted : pnlColor(pnl),
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          const SizedBox(height: 4),
          StatusChip(status, statusColor),
        ]),
      ]),
    );
  }
}
