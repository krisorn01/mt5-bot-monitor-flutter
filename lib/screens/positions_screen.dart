import 'package:flutter/material.dart';

import '../models.dart';
import '../repository.dart';
import '../theme.dart';
import '../widgets.dart';

class PositionsScreen extends StatelessWidget {
  const PositionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = RepositoryScope.of(context);
    final st = repo.status;
    if (st == null && repo.error == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final list = st?.positions ?? const <Position>[];
    return RefreshList(
      onRefresh: repo.refresh,
      children: [
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(
              child: Text('No open positions', style: TextStyle(color: kMuted, fontSize: 15)),
            ),
          ),
        for (final p in list) ...[
          _PositionCard(p),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

String _price(double v) {
  final s = v.toStringAsFixed(v.abs() >= 20 ? 3 : 5);
  return s;
}

class _PositionCard extends StatelessWidget {
  const _PositionCard(this.p);
  final Position p;

  @override
  Widget build(BuildContext context) => AppCard(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(p.symbol,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                StatusChip(p.type, sideColor(p.type)),
              ]),
              const SizedBox(height: 6),
              Text('${p.volume.toStringAsFixed(2)} lots',
                  style: const TextStyle(color: kMuted, fontSize: 13)),
              const SizedBox(height: 4),
              Text('${_price(p.priceOpen)} → ${_price(p.priceCurrent)}',
                  style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Text('SL ${_price(p.sl)}  ·  TP ${_price(p.tp)}',
                  style: const TextStyle(color: kMuted, fontSize: 12)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(signed(p.profit),
                style: TextStyle(
                    color: pnlColor(p.profit), fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('swap ${signed(p.swap)}',
                style: const TextStyle(color: kMuted, fontSize: 11)),
          ]),
        ]),
      );
}
