import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'visual_cards.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.tint = AppColors.rose,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return BudgetSummaryCard(
      title: title,
      value: value,
      icon: icon,
      tint: tint,
    );
  }
}
