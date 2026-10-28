import 'package:flutter/material.dart';

import 'theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(14)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) =>
      Card(child: Padding(padding: padding, child: child));
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, this.color, {super.key});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

Color sideColor(String? side) =>
    side == 'BUY' ? kGreen : (side == 'SELL' ? kRed : kMuted);

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(color: kMuted, fontSize: 12, fontWeight: FontWeight.w600)),
      );
}

class KeyValueRow extends StatelessWidget {
  const KeyValueRow(this.k, this.v, {super.key, this.valueColor});
  final String k;
  final String v;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(color: kMuted, fontSize: 13)),
            Text(v,
                style: TextStyle(
                    color: valueColor ?? kText, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

/// Wraps a scrollable body with pull-to-refresh that always allows overscroll.
class RefreshList extends StatelessWidget {
  const RefreshList({super.key, required this.onRefresh, required this.children});
  final Future<void> Function() onRefresh;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(14),
          children: children,
        ),
      );
}
