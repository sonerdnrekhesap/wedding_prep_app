import 'package:flutter/material.dart';

import '../main.dart';
import '../services/calculation_service.dart';
import '../services/formatters.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/budget_chart.dart';
import '../widgets/summary_card.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final calc = CalculationService();
    final stats = calc.categoryStats(controller.items);
    final topItems = calc.topExpensiveItems(controller.items);
    final missingHigh = calc.missingHighEstimateItems(controller.items);
    final topCategories = stats.entries.toList()
      ..sort((a, b) => b.value.spent.compareTo(a.value.spent));

    return Scaffold(
      appBar: AppBar(title: const Text('Bütçe')),
      bottomNavigationBar: const AdBannerWidget(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.18,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            children: [
              SummaryCard(
                title: 'Hedef bütçe',
                value: money(controller.settings.targetBudget),
                icon: Icons.flag_outlined,
              ),
              SummaryCard(
                title: 'Toplam harcama',
                value: money(calc.totalSpent(controller.items)),
                icon: Icons.payments_outlined,
              ),
              SummaryCard(
                title: 'Kalan bütçe',
                value: money(calc.remainingBudget(
                  controller.settings,
                  controller.items,
                )),
                icon: Icons.savings_outlined,
                tint: const Color(0xFF0D9488),
              ),
              SummaryCard(
                title: 'Tahmini ihtiyaç',
                value: money(calc.totalEstimated(controller.items)),
                icon: Icons.receipt_long_outlined,
                tint: const Color(0xFF5F6FD9),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _Section(
            title: 'Kategori bazlı harcama',
            child: BudgetChart(stats: stats),
          ),
          _Section(
            title: 'En pahalı 5 ürün',
            child: _SimpleList(
              empty: 'Henüz harcama eklenmedi',
              rows: [
                for (final item in topItems)
                  '${item.title} · ${item.mainCategory.label} · ${money(item.actualPrice)}',
              ],
            ),
          ),
          _Section(
            title: 'En çok harcanan 5 kategori',
            child: _SimpleList(
              empty: 'Henüz kategori harcaması yok',
              rows: [
                for (final entry in topCategories.take(5))
                  if (entry.value.spent > 0)
                    '${entry.key.label} · ${money(entry.value.spent)}',
              ],
            ),
          ),
          _Section(
            title: 'Alınmadı ama yüksek tahminli ürünler',
            child: _SimpleList(
              empty: 'Tahmini fiyat girilmiş eksik ürün yok',
              rows: [
                for (final item in missingHigh)
                  if (item.estimatedPrice > 0)
                    '${item.title} · ${item.subCategory} · ${money(item.estimatedPrice)}',
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SimpleList extends StatelessWidget {
  const _SimpleList({required this.rows, required this.empty});

  final List<String> rows;
  final String empty;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return Text(empty);
    return Column(
      children: [
        for (final row in rows)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(row, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
      ],
    );
  }
}
