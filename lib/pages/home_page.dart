import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

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
import 'weekly_plan_page.dart';
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
    final missingMustHave = calc.missingMustHaveItems(controller.items);
    final weeklyActions = calc.weeklyPlanActions(
      controller.settings,
      controller.items,
      controller.guests,
      limit: 3,
    );
    final totalSpent = calc.totalSpent(controller.items);
    final remainingBudget =
        calc.remainingBudget(controller.settings, controller.items);

    final children = <Widget>[
      HomeHeroCard(
        names: controller.settings.coupleNames,
        message: _heroMessage(days),
        score: score / 100,
      ),
      const SizedBox(height: 14),
      ProgressCard(
        title: 'Hazirlik durumun',
        subtitle: calc.scoreMessage(score),
        progress: score / 100,
        trailing: '%${score.round()} tamam',
        icon: Icons.auto_graph,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WrappedSummaryPage()),
        ),
      ),
      const SizedBox(height: 14),
      GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        children: [
          SummaryCard(
            title: 'Kritik eksik',
            value: '${missingMustHave.length}',
            icon: Icons.priority_high,
            tint: AppColors.gold,
          ),
          SummaryCard(
            title: 'Toplam harcama',
            value: money(totalSpent),
            icon: Icons.payments_outlined,
          ),
          SummaryCard(
            title: 'Kalan butce',
            value: money(remainingBudget),
            icon: Icons.savings_outlined,
            tint: AppColors.mint,
          ),
          SummaryCard(
            title: 'Eksik urun',
            value: '${calc.missingItems(controller.items)}',
            icon: Icons.pending_actions_outlined,
            tint: AppColors.roseDeep,
          ),
        ],
      ),
      const SizedBox(height: 16),
      _WeeklyPlanPreview(actions: weeklyActions),
      const SizedBox(height: 10),
      PriorityActionCard(
        title: 'Once ne almaliyim?',
        subtitle: 'Olmazsa olmazlar ve yuksek maliyetli eksikler sirada.',
        icon: Icons.route_outlined,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PriorityPage()),
        ),
      ),
      const SizedBox(height: 10),
      PriorityActionCard(
        title: 'Listeyi paylas',
        subtitle: 'Ailene veya nisanlina hazirlik ozetini gonder.',
        icon: Icons.ios_share,
        onTap: () => Share.share(_shareHomeText(days, score, totalSpent)),
      ),
      const SizedBox(height: 18),
      _SectionTitle(
        title: 'Kontrol noktalari',
        actionLabel: 'Ozet',
        onAction: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WrappedSummaryPage()),
        ),
      ),
      const SizedBox(height: 10),
      ProgressCard(
        title: 'Butce ve harcama',
        subtitle: remainingBudget < 0
            ? 'Hedef butce asildi. Pahali kalemleri kontrol et.'
            : 'Ne kadar harcadigini ve kalan butceni gor.',
        progress:
            calc.budgetUsagePercent(controller.settings, controller.items),
        icon: Icons.account_balance_wallet_outlined,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BudgetPage()),
        ),
      ),
      const SizedBox(height: 10),
      ProgressCard(
        title: 'Davetliler',
        subtitle: 'Gelecek, gelmeyecek ve belirsiz kisi sayilari.',
        progress: controller.guests.isEmpty ? 0 : 1,
        icon: Icons.groups_outlined,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GuestListPage()),
        ),
      ),
      const SizedBox(height: 18),
      const _SectionTitle(title: 'Listeler'),
      const SizedBox(height: 10),
      for (final category in MainCategory.values) ...[
        ProgressCard(
          title: category.label,
          subtitle:
              '${stats[category]!.completed}/${stats[category]!.total} tamamlandi',
          progress: stats[category]!.progress,
          icon: _iconFor(category),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ItemListPage(category: category)),
          ),
        ),
        const SizedBox(height: 10),
      ],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Hazirlik Asistani')),
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

  String _heroMessage(int? days) {
    if (days == null) return 'Tarihi ekleyelim, plani sakin sakin kuralim';
    if (days < 0) return 'Dugun tarihi gecti, anilari toparlama zamani';
    if (days == 0) return 'Bugun buyuk gun. Her sey yolunda.';
    return 'Dugune $days gun kaldi';
  }

  String _shareHomeText(int? days, double score, double spent) {
    return [
      if (days != null) 'Dugunume $days gun kaldi.',
      'Hazirligim %${score.round()} tamamlandi.',
      'Toplam harcama: ${money(spent)}',
      'Panik yok, listeyi birlikte toparliyoruz.',
      'Hazirlik kartim - Hazirlik Takibi',
    ].join('\n');
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

class _WeeklyPlanPreview extends StatelessWidget {
  const _WeeklyPlanPreview({required this.actions});

  final List<WeeklyPlanAction> actions;

  @override
  Widget build(BuildContext context) {
    final subtitle = actions.isEmpty
        ? 'Kritik bir is yok. Haftalik kontrol icin yine de plana bak.'
        : actions.map((action) => action.title).join(' / ');

    return PriorityActionCard(
      title: 'Bu haftanin plani',
      subtitle: subtitle,
      icon: Icons.calendar_month_outlined,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const WeeklyPlanPage()),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}
