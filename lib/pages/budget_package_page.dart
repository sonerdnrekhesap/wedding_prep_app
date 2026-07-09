import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models/item_model.dart';
import '../services/formatters.dart';
import '../theme/app_colors.dart';
import '../widgets/priority_badge.dart';

enum BudgetPackageType { economic, middle, premium, manual }

extension BudgetPackageTypeText on BudgetPackageType {
  String get label => switch (this) {
        BudgetPackageType.economic => 'Ekonomik',
        BudgetPackageType.middle => 'Orta',
        BudgetPackageType.premium => 'Premium',
        BudgetPackageType.manual => 'Manuel',
      };

  double get budget => switch (this) {
        BudgetPackageType.economic => 250000,
        BudgetPackageType.middle => 600000,
        BudgetPackageType.premium => 1200000,
        BudgetPackageType.manual => 0,
      };
}

class BudgetPackagePage extends StatefulWidget {
  const BudgetPackagePage({super.key});

  @override
  State<BudgetPackagePage> createState() => _BudgetPackagePageState();
}

class _BudgetPackagePageState extends State<BudgetPackagePage> {
  BudgetPackageType type = BudgetPackageType.middle;
  final manualBudgetController = TextEditingController();

  @override
  void dispose() {
    manualBudgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final budget = type == BudgetPackageType.manual
        ? parseMoney(manualBudgetController.text)
        : type.budget;
    final missing = controller.items
        .where((item) => !item.isCompleted)
        .toList()
      ..sort((a, b) {
        final priority = a.priority.sortOrder.compareTo(b.priority.sortOrder);
        if (priority != 0) return priority;
        return a.estimatedPrice.compareTo(b.estimatedPrice);
      });
    final recommended = _fitToBudget(missing, budget);

    return Scaffold(
      appBar: AppBar(title: const Text('Bütçeme Göre Paket')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<BudgetPackageType>(
            selected: {type},
            showSelectedIcon: false,
            segments: [
              for (final option in BudgetPackageType.values)
                ButtonSegment(value: option, label: Text(option.label)),
            ],
            onSelectionChanged: (value) => setState(() => type = value.first),
          ),
          if (type == BudgetPackageType.manual) ...[
            const SizedBox(height: 12),
            TextField(
              controller: manualBudgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Manuel bütçe'),
              onChanged: (_) => setState(() {}),
            ),
          ],
          const SizedBox(height: 14),
          _RewardedPlaceholder(
            title: 'Detaylı hazırlık raporu',
            placement: 'detailed_report',
          ),
          const SizedBox(height: 10),
          _RewardedPlaceholder(
            title: 'PDF/Excel çıktı önizlemesi',
            placement: 'export_placeholder',
          ),
          const SizedBox(height: 14),
          Text(
            'Önerilen eksikler · ${money(budget)}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          for (final item in recommended)
            Card(
              child: ListTile(
                title: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    PriorityBadge(priority: item.priority),
                    Text(item.mainCategory.label),
                    if (item.estimatedPrice > 0) Text(money(item.estimatedPrice)),
                  ],
                ),
                trailing: item.affiliateUrl.isEmpty
                    ? const Text('Yakında')
                    : TextButton(
                        onPressed: () => _openAffiliate(item),
                        child: const Text('Fiyatlara Bak'),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  List<PrepItem> _fitToBudget(List<PrepItem> items, double budget) {
    if (budget <= 0) return items.take(25).toList();
    var used = 0.0;
    final result = <PrepItem>[];
    for (final item in items) {
      final estimate = item.estimatedPrice <= 0 ? 1 : item.estimatedPrice;
      if (result.isEmpty || used + estimate <= budget) {
        result.add(item);
        used += estimate;
      }
      if (result.length >= 25) break;
    }
    return result;
  }

  Future<void> _openAffiliate(PrepItem item) async {
    final controller = AppScope.of(context);
    controller.analytics.affiliateClicked(
      source: 'budget_package:${item.title}',
      url: item.affiliateUrl,
    );
    await launchUrl(
      Uri.parse(item.affiliateUrl),
      mode: LaunchMode.externalApplication,
    );
  }
}

class _RewardedPlaceholder extends StatelessWidget {
  const _RewardedPlaceholder({
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
        subtitle: const Text('Ödüllü reklamla açılacak gelir alanı.'),
        onTap: () async {
          final controller = AppScope.of(context);
          controller.analytics.budgetPackageOpened(packageType: placement);
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
