import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../main.dart';
import '../models/item_model.dart';
import '../services/formatters.dart';
import '../theme/app_colors.dart';
import '../widgets/priority_badge.dart';
import '../widgets/visual_cards.dart';

class GiftListPage extends StatelessWidget {
  const GiftListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final selected = controller.items
        .where((item) => item.isGiftListed)
        .toList()
      ..sort((a, b) => a.priority.sortOrder.compareTo(b.priority.sortOrder));
    final candidates = controller.items
        .where((item) => !item.isCompleted && !item.isGiftListed)
        .toList()
      ..sort((a, b) => a.priority.sortOrder.compareTo(b.priority.sortOrder));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hediye Listem'),
        actions: [
          IconButton(
            tooltip: 'Paylaş',
            onPressed: selected.isEmpty ? null : () => _share(context, selected),
            icon: const Icon(Icons.ios_share),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _RewardedActionCard(
            title: 'Premium hediye listesi teması',
            subtitle: 'Daha şık paylaşım görünümü için ödüllü reklamla önizle.',
            placement: 'gift_list_theme',
          ),
          const SizedBox(height: 14),
          Text(
            'Paylaşılacak liste',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          if (selected.isEmpty)
            const EmptyStateCard(
              icon: Icons.card_giftcard_outlined,
              title: 'Hediye listesi boş',
              message: 'Eksik ürünlerden hediye listene ekleyebilirsin.',
            )
          else
            for (final item in selected)
              _GiftItemTile(
                item: item,
                actionLabel: 'Çıkar',
                onTap: () => controller.toggleGiftList(item),
              ),
          const SizedBox(height: 18),
          Text(
            'Eksiklerden ekle',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          for (final item in candidates.take(40))
            _GiftItemTile(
              item: item,
              actionLabel: 'Ekle',
              onTap: () => controller.toggleGiftList(item),
            ),
        ],
      ),
    );
  }

  Future<void> _share(BuildContext context, List<PrepItem> items) async {
    final controller = AppScope.of(context);
    final text = [
      'Hediye listem',
      '',
      for (final item in items)
        '- ${item.title} (${item.mainCategory.label}) ${item.estimatedPrice > 0 ? money(item.estimatedPrice) : ''}',
      if (!controller.settings.isPremium) '',
      if (!controller.settings.isPremium)
        'Hazırlık Takibi uygulamasıyla oluşturuldu.',
    ].join('\n');
    controller.analytics.giftListShared(itemCount: items.length);
    await Share.share(text);
  }
}

class _GiftItemTile extends StatelessWidget {
  const _GiftItemTile({
    required this.item,
    required this.actionLabel,
    required this.onTap,
  });

  final PrepItem item;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            PriorityBadge(priority: item.priority),
            Text(item.mainCategory.label),
            if (item.estimatedPrice > 0) Text(money(item.estimatedPrice)),
          ],
        ),
        trailing: TextButton(onPressed: onTap, child: Text(actionLabel)),
      ),
    );
  }
}

class _RewardedActionCard extends StatelessWidget {
  const _RewardedActionCard({
    required this.title,
    required this.subtitle,
    required this.placement,
  });

  final String title;
  final String subtitle;
  final String placement;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cream,
      child: ListTile(
        leading: const Icon(Icons.workspace_premium, color: AppColors.gold),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.play_circle_outline),
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
