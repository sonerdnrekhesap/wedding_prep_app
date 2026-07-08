import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

import '../main.dart';
import '../models/item_model.dart';
import '../services/app_controller.dart';
import '../services/calculation_service.dart';
import '../services/formatters.dart';
import '../theme/app_spacing.dart';
import '../widgets/visual_cards.dart';

class WrappedSummaryPage extends StatelessWidget {
  const WrappedSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final calc = CalculationService();
    final score = calc.weightedPreparationScore(controller.items);
    final topCategory = calc.topSpentCategory(controller.items);
    final topItems = calc.topExpensiveItems(controller.items, limit: 1);
    final topItem = topItems.isEmpty ? null : topItems.first;
    final ceyizItems = controller.items
        .where((item) => item.mainCategory == MainCategory.ceyiz)
        .toList();
    final ceyizProgress = ceyizItems.isEmpty
        ? 0
        : calc.completedItems(ceyizItems) / ceyizItems.length;
    final mustHave = controller.items
        .where((item) => item.priority == ItemPriority.mustHave)
        .toList();
    final mustHaveProgress =
        mustHave.isEmpty ? 0 : calc.completedItems(mustHave) / mustHave.length;
    final missingCategory = calc.mostMissingCategory(controller.items);
    final days = calc.daysUntilWedding(controller.settings);

    final stories = [
      _StoryData(
        title: 'Toplam harcama',
        value: money(calc.totalSpent(controller.items)),
        icon: Icons.payments_outlined,
        shareable: true,
      ),
      _StoryData(
        title: 'En çok harcanan kategori',
        value: topCategory?.label ?? 'Henüz yok',
        icon: Icons.pie_chart_outline,
        shareable: true,
      ),
      _StoryData(
        title: 'En pahalı ürün',
        value: topItem == null
            ? 'Henüz yok'
            : '${topItem.title}\n${money(topItem.actualPrice)}',
        icon: Icons.local_offer_outlined,
      ),
      _StoryData(
        title: 'Çeyiz tamamlanma',
        value: '%${(ceyizProgress * 100).round()}',
        icon: Icons.kitchen_outlined,
        shareable: true,
      ),
      _StoryData(
        title: 'Olmazsa olmaz tamamlanma',
        value: '%${(mustHaveProgress * 100).round()}',
        icon: Icons.priority_high,
        shareable: true,
      ),
      _StoryData(
        title: 'En eksik kategori',
        value: missingCategory?.label ?? 'Hesaplanamadı',
        icon: Icons.pending_actions_outlined,
        premium: true,
      ),
      _StoryData(
        title: 'Düğüne kalan gün',
        value: days == null ? 'Tarih yok' : '$days gün',
        icon: Icons.event_outlined,
        shareable: true,
      ),
      _StoryData(
        title: 'Hazırlık skoru',
        value: '%${score.round()}',
        icon: Icons.auto_graph,
        shareable: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hazırlık Özeti'),
        actions: [
          IconButton(
            tooltip: 'Özet metnini paylaş',
            onPressed: () => Share.share(_shareText(stories, controller)),
            icon: const Icon(Icons.ios_share),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.88),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                final locked = story.premium && !controller.settings.isPremium;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: WrappedStoryCard(
                          index: index,
                          total: stories.length,
                          title: locked ? 'Premium ile aç' : story.title,
                          value: locked ? 'Kilitli kart' : story.value,
                          icon: story.icon,
                          locked: locked,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ShareActions(
                        enabled: !locked && story.shareable,
                        onShare: () => Share.share(
                          _shareCardText(story, controller),
                        ),
                        onTextShare: () => Share.share(
                          _shareCardText(story, controller),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 360.ms).slideX(begin: 0.06),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _shareDetailedSummary(context, stories),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Özeti paylaş'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shareText(List<_StoryData> stories, AppController controller) {
    final calc = CalculationService();
    final days = calc.daysUntilWedding(controller.settings);
    final score = calc.weightedPreparationScore(controller.items).round();
    final topCategory = calc.topSpentCategory(controller.items);
    return [
      days == null
          ? 'Düğün tarihim yaklaşıyor 🎉'
          : 'Düğünüme $days gün kaldı 🎉',
      'Hazırlığım %$score tamamlandı.',
      'En çok harcama: ${topCategory?.label ?? 'Henüz yok'}',
      'Ben çeyiz hazırlığımı uygulama ile takip ediyorum.',
      '',
      'Hazırlık kartım — Hazırlık Takibi',
      '----------------',
      for (final story in stories.where((story) => !story.premium))
        '${story.title}: ${story.value}',
    ].join('\n');
  }

  String _shareCardText(_StoryData story, AppController controller) {
    final days = CalculationService().daysUntilWedding(controller.settings);
    return [
      if (days != null) 'Düğünüme $days gün kaldı 🎉',
      '${story.title}: ${story.value}',
      'Ben çeyiz hazırlığımı uygulama ile takip ediyorum.',
      'Hazırlık kartım — Hazırlık Takibi',
    ].join('\n');
  }

  Future<void> _shareDetailedSummary(
    BuildContext context,
    List<_StoryData> stories,
  ) async {
    final controller = AppScope.of(context);
    await Share.share(_shareText(stories, controller));
  }
}

class _StoryData {
  const _StoryData({
    required this.title,
    required this.value,
    required this.icon,
    this.premium = false,
    this.shareable = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool premium;
  final bool shareable;
}

class _ShareActions extends StatelessWidget {
  const _ShareActions({
    required this.enabled,
    required this.onShare,
    required this.onTextShare,
  });

  final bool enabled;
  final VoidCallback onShare;
  final VoidCallback onTextShare;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return const SizedBox(
        height: 44,
        child: Center(child: Text('Premium kart')),
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: onShare,
          icon: const Icon(Icons.ios_share),
          label: const Text('Paylaş'),
        ),
        OutlinedButton.icon(
          onPressed: onShare,
          icon: const Icon(Icons.download_outlined),
          label: const Text('Kartı kaydet/paylaş'),
        ),
        TextButton.icon(
          onPressed: onTextShare,
          icon: const Icon(Icons.text_snippet_outlined),
          label: const Text('Metin'),
        ),
      ],
    );
  }
}
