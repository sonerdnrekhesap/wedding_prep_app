import 'package:flutter/material.dart';

import 'visual_cards.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.trailing,
    this.onTap,
    this.icon = Icons.trending_up,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String? trailing;
  final VoidCallback? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ProgressSummaryCard(
      title: title,
      subtitle: subtitle,
      progress: progress,
      trailing: trailing,
      icon: icon,
      onTap: onTap,
    );
  }
}
