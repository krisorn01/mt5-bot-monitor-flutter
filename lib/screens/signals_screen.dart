import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models.dart';
import '../repository.dart';
import '../theme.dart';
import '../widgets.dart';

final DateFormat _fmt = DateFormat('HH:mm dd/MM');

class SignalsScreen extends StatelessWidget {
  const SignalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = RepositoryScope.of(context);
    if (repo.status == null && repo.error == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final list = repo.signals;
    return RefreshList(
      onRefresh: repo.refresh,
      children: [
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(child: Text('No signals yet', style: TextStyle(color: kMuted))),
          ),
        for (final s in list) ...[
          _SignalRowView(s),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _SignalRowView extends StatelessWidget {
  const _SignalRowView(this.s);
  final SignalRow s;

  @override
  Widget build(BuildContext context) {
    final String result;
    final Color resultColor;
    if (s.action == null) {
      result = 'no-sig';
      resultColor = kMuted;
    } else if (s.executed) {
      result = 'exec';
      resultColor = kGreen;
    } else {
      result = 'skip';
      resultColor = kAmber;
    }
    final action = s.action;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(s.dt == null ? '-' : _fmt.format(s.dt!),
              style: const TextStyle(color: kMuted, fontSize: 12)),
          const SizedBox(width: 10),
          Text(s.symbol, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          StatusChip(action ?? '-', sideColor(action)),
          const Spacer(),
          StatusChip(result, resultColor),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: s.strength.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: kOutline,
                color: action == null ? kMuted : sideColor(action),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(s.strength.toStringAsFixed(2), style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 12),
          Text('H1 RSI ${s.h1Rsi.toStringAsFixed(1)}',
              style: const TextStyle(color: kMuted, fontSize: 12)),
        ]),
        if (s.rejectReason.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(s.rejectReason, style: const TextStyle(color: kAmber, fontSize: 11)),
        ],
      ]),
    );
  }
}
