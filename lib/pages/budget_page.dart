import 'package:flutter/material.dart';

import '../main.dart';
import '../models/item_model.dart';
import '../services/calculation_service.dart';
import '../services/formatters.dart';
import '../theme/app_colors.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/budget_chart.dart';
import '../widgets/summary_card.dart';
import '../widgets/visual_cards.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final calc = CalculationService();
    final stats = calc.categoryStats(controller.items);
    final topItems = calc.topExpensiveItems(controller.items);
    final missingHigh = calc.missingHighEstimateItems(controller.items);
    final totalSpent = calc.totalSpent(controller.items);
    final remainingBudget =
        calc.remainingBudget(controller.settings, controller.items);
    final topCategories = stats.entries.toList()
      ..sort((a, b) => b.value.spent.compareTo(a.value.spent));
    final topSpentCategory = calc.topSpentCategory(controller.items);

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
                value: money(totalSpent),
                icon: Icons.payments_outlined,
              ),
              SummaryCard(
                title: 'Kalan bütçe',
                value: money(remainingBudget),
                icon: Icons.savings_outlined,
                tint: remainingBudget < 0 ? AppColors.coral : AppColors.mint,
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
          if (controller.settings.targetBudget > 0 && remainingBudget < 0)
            _Section(
              title: 'Bütçe aşımı',
              child: _WarningCard(
                message:
                    'Hedef bütçe ${money(remainingBudget.abs())} aşıldı. Önce lüks ve ertelenebilir kalemlere bak.',
              ),
            ),
          _Section(
            title: 'Paran nereye gitti?',
            child: totalSpent == 0
                ? const EmptyStateCard(
                    icon: Icons.savings_outlined,
                    title: 'Henüz harcama eklenmedi',
                    message:
                        'Gerçek fiyat girdikçe kategori yüzdeleri burada netleşir.',
                  )
                : Column(
                    children: [
                      _BudgetComment(
                        comment: _spendingComment(topSpentCategory, stats),
                      ),
                      const SizedBox(height: 12),
                      for (final entry in topCategories
                          .where((entry) => entry.value.spent > 0))
                        _CategoryShareRow(
                          category: entry.key,
                          spent: entry.value.spent,
                          percent: entry.value.spent / totalSpent,
                        ),
                    ],
                  ),
          ),
          _Section(
            title: 'Gelişmiş bütçe yorumu',
            child: _RewardedBudgetAction(
              title: 'Ödüllü reklamla detaylı yorumu aç',
              placement: 'advanced_budget_comment',
            ),
          ),
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

  String _spendingComment(
    MainCategory? topCategory,
    Map<MainCategory, CategoryStats> stats,
  ) {
    if (topCategory == null) return 'Henüz harcama eklenmedi.';
    if (topCategory == MainCategory.dugun) {
      return 'En çok harcama düğün tarafına gitmiş.';
    }
    if (topCategory == MainCategory.ceyiz) {
      return 'Beyaz eşya ve ev kurma kalemleri bütçeyi zorluyor olabilir.';
    }
    if (topCategory == MainCategory.balayi) {
      return 'Balayı tarafı bütçede belirginleşmiş.';
    }
    final spent = stats[topCategory]?.spent ?? 0;
    return '${topCategory.label} kategorisi ${money(spent)} ile en yüksek harcama alanı.';
  }
}

class _BudgetComment extends StatelessWidget {
  const _BudgetComment({required this.comment});

  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        comment,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.coral.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.coral),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardedBudgetAction extends StatelessWidget {
  const _RewardedBudgetAction({
    required this.title,
    required this.placement,
  });

  final String title;
  final String placement;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cream,
      child: ListTile(
        leading: const Icon(Icons.play_circle_outline, color: AppColors.gold),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: const Text(
          'Gerçek rapor altyapısı bağlanana kadar ödüllü reklam alanı.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () async {
          final controller = AppScope.of(context);
          controller.analytics.rewardedAdStarted(placement: placement);
          final completed = await controller.ads.showRewardedForFeature();
          if (completed) {
            controller.analytics.rewardedAdCompleted(placement: placement);
          }
        },
      ),
    );
  }
}

class _CategoryShareRow extends StatelessWidget {
  const _CategoryShareRow({
    required this.category,
    required this.spent,
    required this.percent,
  });

  final MainCategory category;
  final double spent;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${(percent * 100).round()}% · ${money(spent)}',
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: percent.clamp(0, 1).toDouble(),
              minHeight: 8,
              backgroundColor: AppColors.creamDeep,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.rose),
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
