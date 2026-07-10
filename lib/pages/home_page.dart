import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

import '../main.dart';
import '../models/item_model.dart';
import '../services/app_controller.dart';
import '../services/calculation_service.dart';
import '../services/formatters.dart';
import '../theme/app_colors.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/progress_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/visual_cards.dart';
import 'budget_page.dart';
import 'budget_package_page.dart';
import 'gift_list_page.dart';
import 'guest_list_page.dart';
import 'item_list_page.dart';
import 'lead_request_page.dart';
import 'paywall_page.dart';
import 'product_recommendations_page.dart';
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
    final missingMustHave = calc.missingMustHaveItems(controller.items);
    final todayItems = calc.nextActionItems(controller.items);
    final totalSpent = calc.totalSpent(controller.items);
    final smartAlerts = _smartAlerts(context, controller, calc, days);

    final children = <Widget>[
      HomeHeroCard(
        names: controller.settings.coupleNames,
        message: _heroMessage(days),
        score: score / 100,
      ),
      const SizedBox(height: 14),
      ProgressCard(
        title: 'HazÄ±rlÄ±k durumun',
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
            title: 'Kalan bÃ¼tÃ§e',
            value: money(
                calc.remainingBudget(controller.settings, controller.items)),
            icon: Icons.savings_outlined,
            tint: AppColors.mint,
          ),
          SummaryCard(
            title: 'Eksik Ã¼rÃ¼n',
            value: '${calc.missingItems(controller.items)}',
            icon: Icons.pending_actions_outlined,
            tint: AppColors.roseDeep,
          ),
        ],
      ),
      const SizedBox(height: 16),
      PriorityActionCard(
        title: 'BugÃ¼n bunlara bak',
        subtitle: todayItems.isEmpty
            ? 'Åimdilik kritik eksik gÃ¶rÃ¼nmÃ¼yor. GÃ¼zel gidiyorsun.'
            : todayItems.take(3).map((item) => item.title).join(' Â· '),
        icon: Icons.today_outlined,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PriorityPage()),
        ),
      ),
      if (smartAlerts.isNotEmpty) ...[
        const SizedBox(height: 18),
        const _SectionTitle(title: 'AkÄ±llÄ± Eksik UyarÄ±larÄ±'),
        const SizedBox(height: 10),
        for (final alert in smartAlerts) ...[
          PriorityActionCard(
            title: alert.title,
            subtitle: alert.subtitle,
            icon: alert.icon,
            onTap: alert.onTap,
          ),
          const SizedBox(height: 10),
        ],
      ],
      const SizedBox(height: 10),
      PriorityActionCard(
        title: 'Listeyi paylaÅŸ',
        subtitle: 'Ailene veya niÅŸanlÄ±na Ã¶zet kartÄ± Ã¼cretsiz gÃ¶nder.',
        icon: Icons.ios_share,
        onTap: () => Share.share(_shareHomeText(days, score, totalSpent)),
      ),
      const SizedBox(height: 18),
      const _SectionTitle(title: 'FÄ±rsat ve gelir alanlarÄ±'),
      const SizedBox(height: 10),
      PriorityActionCard(
        title: 'Fiyatlara Bak / ÃœrÃ¼n Ã–nerileri',
        subtitle: 'Kategori bazlÄ± Ã¼rÃ¼n ve affiliate link alanlarÄ±.',
        icon: Icons.shopping_bag_outlined,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ProductRecommendationsPage(),
          ),
        ),
      ),
      const SizedBox(height: 10),
      PriorityActionCard(
        title: 'Hediye Listem',
        subtitle: 'Eksikleri paylaÅŸÄ±labilir hediye listesine dÃ¶nÃ¼ÅŸtÃ¼r.',
        icon: Icons.card_giftcard_outlined,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GiftListPage()),
        ),
      ),
      const SizedBox(height: 10),
      PriorityActionCard(
        title: 'BÃ¼tÃ§eme GÃ¶re Paket',
        subtitle: 'Ekonomik, orta veya premium bÃ¼tÃ§eye gÃ¶re eksikleri sÄ±rala.',
        icon: Icons.inventory_2_outlined,
        onTap: () {
          controller.analytics.budgetPackageOpened(packageType: 'home');
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BudgetPackagePage()),
          );
        },
      ),
      const SizedBox(height: 10),
      PriorityActionCard(
        title: 'Teklif Al',
        subtitle: 'Salon, fotoÄŸrafÃ§Ä±, balayÄ± ve paket taleplerini kaydet.',
        icon: Icons.request_quote_outlined,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LeadRequestPage()),
        ),
      ),
      const SizedBox(height: 10),
      PriorityActionCard(
        title: 'DetaylÄ± Rapor / Pro',
        subtitle: 'Premium ve Ã¶dÃ¼llÃ¼ reklam gelir alanlarÄ±nÄ± gÃ¶r.',
        icon: Icons.workspace_premium_outlined,
        onTap: () {
          controller.analytics.proClicked(source: 'home');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PaywallPage(source: 'home'),
            ),
          );
        },
      ),
      const SizedBox(height: 18),
      _SectionTitle(
        title: 'Kontrol noktalarÄ±',
        actionLabel: 'Ã–zet',
        onAction: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WrappedSummaryPage()),
        ),
      ),
      const SizedBox(height: 10),
      ProgressCard(
        title: 'Neyi Ã¶nce almalÄ±yÄ±m?',
        subtitle: 'Olmazsa olmazlar ve gerekli Ã¼rÃ¼nler Ã¶nde.',
        progress: controller.items.isEmpty
            ? 0
            : 1 - (missingMustHave.length / controller.items.length),
        icon: Icons.route_outlined,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PriorityPage()),
        ),
      ),
      const SizedBox(height: 10),
      ProgressCard(
        title: 'BÃ¼tÃ§e ve harcama',
        subtitle: 'Ne kadar harcadÄ±ÄŸÄ±nÄ± ve pahalÄ± kalemleri gÃ¶r.',
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
        subtitle: 'Gelecek, gelmeyecek ve belirsiz kiÅŸi sayÄ±larÄ±.',
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
              '${stats[category]!.completed}/${stats[category]!.total} tamamlandÄ±',
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
      appBar: AppBar(title: const Text('HazÄ±rlÄ±k AsistanÄ±')),
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
    if (days == null) return 'Tarihi ekleyelim, planÄ± sakin sakin kuralÄ±m';
    if (days < 0) return 'DÃ¼ÄŸÃ¼n tarihi geÃ§ti, anÄ±larÄ± toparlama zamanÄ±';
    if (days == 0) return 'BugÃ¼n bÃ¼yÃ¼k gÃ¼n. Her ÅŸey yolunda.';
    return 'DÃ¼ÄŸÃ¼ne $days gÃ¼n kaldÄ±';
  }

  String _shareHomeText(int? days, double score, double spent) {
    return [
      if (days != null) 'Düğünüme $days gün kaldı.',
      'Hazırlığım %${score.round()} tamamlandı.',
      'Toplam harcama: ${money(spent)}',
      'Hazırlık listemi düzenli şekilde takip ediyorum.',
      'Hazırlık kartım - Hazırlık Takibi',
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

  List<_SmartAlert> _smartAlerts(
    BuildContext context,
    AppController controller,
    CalculationService calc,
    int? days,
  ) {
    final alerts = <_SmartAlert>[];
    final items = controller.items;
    final missingMustHave = calc.missingMustHaveItems(items);
    final budgetUsage = calc.budgetUsagePercent(controller.settings, items);
    final luxuryCompleted = items.any(
      (item) => item.priority == ItemPriority.luxury && item.isCompleted,
    );
    final missingCategory = calc.mostMissingCategory(items);
    final balayiCriticalMissing = items.any((item) {
      final title = item.title.toLowerCase();
      return item.mainCategory == MainCategory.balayi &&
          !item.isCompleted &&
          (title.contains('pasaport') || title.contains('vize'));
    });

    void goPriority() => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PriorityPage()),
        );
    void goCategory(MainCategory category) => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ItemListPage(category: category)),
        );

    if (days != null && days < 90 && missingMustHave.isNotEmpty) {
      alerts.add(_SmartAlert(
        title: 'Kritik eksikler yaklaÅŸÄ±yor',
        subtitle:
            'DÃ¼ÄŸÃ¼ne 90 gÃ¼nden az kaldÄ±; ${missingMustHave.length} olmazsa olmaz eksik var.',
        icon: Icons.warning_amber_rounded,
        onTap: goPriority,
      ));
    }
    if (controller.settings.targetBudget > 0 && budgetUsage > 0.8) {
      alerts.add(_SmartAlert(
        title: 'BÃ¼tÃ§e alarmÄ±',
        subtitle:
            'Hedef bÃ¼tÃ§enin %${(budgetUsage * 100).round()} kadarÄ± kullanÄ±ldÄ±.',
        icon: Icons.account_balance_wallet_outlined,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BudgetPage()),
        ),
      ));
    }
    if (luxuryCompleted && missingMustHave.isNotEmpty) {
      alerts.add(_SmartAlert(
        title: 'LÃ¼ks tamam, kritik bekliyor',
        subtitle:
            'BazÄ± lÃ¼ks kalemler tamam ama olmazsa olmazlarda hÃ¢lÃ¢ eksik var.',
        icon: Icons.diamond_outlined,
        onTap: goPriority,
      ));
    }
    if (missingCategory != null) {
      final stats = calc.categoryStats(items)[missingCategory]!;
      alerts.add(_SmartAlert(
        title: 'En eksik alan: ${missingCategory.label}',
        subtitle: '${stats.missing} eksik kalem var; buraya bir gÃ¶z atalÄ±m.',
        icon: _iconFor(missingCategory),
        onTap: () => goCategory(missingCategory),
      ));
    }
    if (days != null && days < 60 && balayiCriticalMissing) {
      alerts.add(_SmartAlert(
        title: 'BalayÄ± evrakÄ±nÄ± unutma',
        subtitle: 'Pasaport veya vize eksik gÃ¶rÃ¼nÃ¼yor; sÃ¼re daralÄ±yor.',
        icon: Icons.flight_takeoff_outlined,
        onTap: () => goCategory(MainCategory.balayi),
      ));
    }

    return alerts.take(3).toList();
  }
}

class _SmartAlert {
  const _SmartAlert({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
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
