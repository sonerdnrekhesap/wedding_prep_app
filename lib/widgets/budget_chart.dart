import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../services/calculation_service.dart';
import '../theme/app_colors.dart';
import 'visual_cards.dart';

class BudgetChart extends StatelessWidget {
  const BudgetChart({super.key, required this.stats});

  final Map<MainCategory, CategoryStats> stats;

  @override
  Widget build(BuildContext context) {
    final entries = stats.entries
        .where((entry) => entry.value.spent > 0)
        .toList(growable: false);
    if (entries.isEmpty) {
      return const EmptyStateCard(
        icon: Icons.receipt_long_outlined,
        title: 'Henüz harcama yok',
        message: 'Ürünlere gerçek fiyat ekledikçe grafik burada canlanır.',
      );
    }

    final maxSpent = entries
        .map((entry) => entry.value.spent)
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxSpent * 1.2,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      entries[index].key.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var index = 0; index < entries.length; index++)
              BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entries[index].value.spent,
                    color: AppColors.rose,
                    width: 18,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
          ],
        ),
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}
