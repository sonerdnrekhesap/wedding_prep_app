import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../main.dart';
import '../models/item_model.dart';
import '../services/calculation_service.dart';
import '../services/formatters.dart';
import '../theme/app_colors.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/progress_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/visual_cards.dart';
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

    final children = <Widget>[
      HomeHeroCard(
        names: controller.settings.coupleNames,
        message: days == null
            ? 'Düğün tarihini ayarlardan ekle'
            : days < 0
                ? 'Düğün tarihi geçti'
                : 'Düğüne $days gün kaldı',
        score: score / 100,
      ),
      const SizedBox(height: 16),
      ProgressCard(
        title: 'Genel hazırlık',
        subtitle: calc.scoreMessage(score),
        progress: score / 100,
        trailing: '%${score.round()} skor',
        icon: Icons.auto_graph,
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
            tint: AppColors.mint,
          ),
          SummaryCard(
            title: 'Eksik ürün',
            value: '${calc.missingItems(controller.items)}',
            icon: Icons.pending_actions_outlined,
            tint: AppColors.roseDeep,
          ),
          SummaryCard(
            title: 'Olmazsa olmaz eksik',
            value: '$missingMustHave',
            icon: Icons.priority_high,
            tint: AppColors.gold,
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
          icon: _iconFor(category),
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
        icon: Icons.groups_outlined,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const GuestListPage(),
        )),
      ),
      const SizedBox(height: 10),
      ProgressCard(
        title: 'Bütçe',
        subtitle: 'Harcama dağılımı ve pahalı kalemler',
        progress:
            calc.budgetUsagePercent(controller.settings, controller.items),
        icon: Icons.account_balance_wallet_outlined,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const BudgetPage(),
        )),
      ),
      const SizedBox(height: 10),
      ProgressCard(
        title: 'Önce Ne Almalıyım?',
        subtitle: 'Eksikleri öncelik sırasına göre gör',
        progress: controller.items.isEmpty
            ? 0
            : 1 - (missingMustHave / controller.items.length),
        icon: Icons.route_outlined,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const PriorityPage(),
        )),
      ),
      const SizedBox(height: 10),
      ProgressCard(
        title: 'Hazırlık Özeti',
        subtitle: 'Hikaye kartlarıyla süreç özeti',
        progress: score / 100,
        icon: Icons.auto_awesome_outlined,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const WrappedSummaryPage(),
        )),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      bottomNavigationBar: const AdBannerWidget(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children:
            children.animate(interval: 70.ms).fadeIn(duration: 360.ms).slideY(
                  begin: 0.08,
                  end: 0,
                  duration: 360.ms,
                  curve: Curves.easeOutCubic,
                ),
      ),
    );
  }

  IconData _iconFor(MainCategory category) => switch (category) {
        MainCategory.ceyiz => Icons.kitchen_outlined,
        MainCategory.bohca => Icons.card_giftcard_outlined,
        MainCategory.soz => Icons.diamond_outlined,
        MainCategory.nisan => Icons.celebration_outlined,
        MainCategory.kina => Icons.local_florist_outlined,
        MainCategory.dugun => Icons.favorite_border,
        MainCategory.balayi => Icons.flight_takeoff_outlined,
      };
}
