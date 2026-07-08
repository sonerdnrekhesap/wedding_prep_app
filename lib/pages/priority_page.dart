import 'package:flutter/material.dart';

import '../main.dart';
import '../models/item_model.dart';
import '../services/formatters.dart';
import '../widgets/priority_badge.dart';
import '../widgets/visual_cards.dart';
import 'paywall_page.dart';

class PriorityPage extends StatefulWidget {
  const PriorityPage({super.key});

  @override
  State<PriorityPage> createState() => _PriorityPageState();
}

class _PriorityPageState extends State<PriorityPage> {
  bool unlockedWithReward = false;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final items = controller.items.where((item) => !item.isCompleted).toList()
      ..sort((a, b) => a.priority.sortOrder.compareTo(b.priority.sortOrder));

    final canUseSmartPlan = controller.settings.isPremium || unlockedWithReward;

    return Scaffold(
      appBar: AppBar(title: const Text('Önce Ne Almalıyım?')),
      body: canUseSmartPlan
          ? _SmartPlanList(items: items)
          : _SmartPlanPreview(
              items: items,
              onReward: () => _unlockWithReward(context),
              onPremium: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PaywallPage(source: 'smart-plan'),
                ),
              ),
            ),
    );
  }

  Future<void> _unlockWithReward(BuildContext context) async {
    final rewarded = await AppScope.of(context).ads.showRewardedForFeature();
    if (!context.mounted) return;
    if (rewarded) {
      setState(() => unlockedWithReward = true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reklam şu an hazır değil. Premium ile sınırsız açılır.'),
      ),
    );
  }
}

class _SmartPlanPreview extends StatelessWidget {
  const _SmartPlanPreview({
    required this.items,
    required this.onReward,
    required this.onPremium,
  });

  final List<PrepItem> items;
  final VoidCallback onReward;
  final VoidCallback onPremium;

  @override
  Widget build(BuildContext context) {
    final preview = items.take(3).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akıllı plan premium özelliktir',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Önce birkaç eksik kalemi gösteriyoruz. Tam akıllı sıralama için premium kullanabilir veya bir reklam izleyerek bu seferlik açabilirsin.',
                  style: TextStyle(color: Color(0xFF6F6470)),
                ),
                const SizedBox(height: 14),
                for (final item in preview)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.priority_high),
                    title: Text(item.title),
                    subtitle:
                        Text('${item.subCategory} · ${item.priority.label}'),
                  ),
                const SizedBox(height: 10),
                PremiumLockedCard(
                  title: 'Tam akıllı plan kilitli',
                  subtitle:
                      'Öncelik, tahmini bütçe ve kritik eksikleri birlikte sıralar.',
                  onTap: onPremium,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReward,
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Reklamla aç'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onPremium,
                        icon: const Icon(Icons.workspace_premium_outlined),
                        label: const Text('Premium'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SmartPlanList extends StatelessWidget {
  const _SmartPlanList({required this.items});

  final List<PrepItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final priority in ItemPriority.values)
          _PrioritySection(
            priority: priority,
            items: items
                .where((item) => item.priority == priority)
                .toList(growable: false),
          ),
      ],
    );
  }
}

class _PrioritySection extends StatelessWidget {
  const _PrioritySection({required this.priority, required this.items});

  final ItemPriority priority;
  final List<PrepItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PriorityBadge(priority: priority),
            const SizedBox(height: 10),
            if (items.isEmpty)
              Text(priority == ItemPriority.mustHave
                  ? 'Olmazsa olmazların tamam!'
                  : 'Bu bölümde eksik yok')
            else
              for (final item in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.title),
                  subtitle: Text(
                    '${item.subCategory} · ${money(item.estimatedPrice)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(item.mainCategory.label),
                ),
          ],
        ),
      ),
    );
  }
}
