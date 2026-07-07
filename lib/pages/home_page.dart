import 'package:flutter/material.dart';

import '../main.dart';
import '../models/item_model.dart';
import '../services/calculation_service.dart';
import '../services/formatters.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/progress_card.dart';
import '../widgets/summary_card.dart';
import 'budget_page.dart';
import 'guest_list_page.dart';
import 'item_list_page.dart';
import 'priority_page.dart';
import 'wrapped_summary_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final calc = CalculationService();
    final days = calc.daysUntilWedding(controller.settings);
    final score = calc.weightedPreparationScore(controller.items);
    final stats = calc.categoryStats(controller.items);
    final missingMustHave = calc.missingMustHaveItems(controller.items).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      bottomNavigationBar: const AdBannerWidget(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE84A7A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.settings.coupleNames.isEmpty
                      ? 'Hazırlık takibi'
                      : controller.settings.coupleNames,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  days == null
                      ? 'Düğün tarihini ayarlardan ekle'
                      : days < 0
                          ? 'Düğün tarihi geçti'
                          : 'Düğüne $days gün kaldı',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ProgressCard(
            title: 'Genel hazırlık',
            subtitle: calc.scoreMessage(score),
            progress: score / 100,
            trailing: '%${score.round()} skor',
          ),
          const SizedBox(height: 16),
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
                title: 'Eksik ürün',
                value: '${calc.missingItems(controller.items)}',
                icon: Icons.pending_actions_outlined,
                tint: const Color(0xFF5F6FD9),
              ),
              SummaryCard(
                title: 'Olmazsa olmaz eksik',
                value: '$missingMustHave',
                icon: Icons.priority_high,
                tint: const Color(0xFFB7791F),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Kategori ilerlemeleri',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          for (final category in MainCategory.values) ...[
            ProgressCard(
              title: category.label,
              subtitle:
                  '${stats[category]!.completed}/${stats[category]!.total} tamamlandı',
              progress: stats[category]!.progress,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ItemListPage(category: category),
              )),
            ),
            const SizedBox(height: 10),
          ],
          ProgressCard(
            title: 'Davetli',
            subtitle: 'Davetli listesi ve kişi sayıları',
            progress: controller.guests.isEmpty ? 0 : 1,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const GuestListPage(),
            )),
          ),
          const SizedBox(height: 10),
          ProgressCard(
            title: 'Bütçe',
            subtitle: 'Harcama dağılımı ve pahalı kalemler',
            progress: calc.budgetUsagePercent(controller.settings, controller.items),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const BudgetPage(),
            )),
          ),
          const SizedBox(height: 10),
          ProgressCard(
            title: 'Önce Ne Almalıyım?',
            subtitle: 'Eksikleri öncelik sırasına göre gör',
            progress: 1 - (missingMustHave / controller.items.length),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const PriorityPage(),
            )),
          ),
          const SizedBox(height: 10),
          ProgressCard(
            title: 'Hazırlık Özeti',
            subtitle: 'Hikaye kartlarıyla süreç özeti',
            progress: score / 100,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const WrappedSummaryPage(),
            )),
          ),
        ],
      ),
    );
  }
}
