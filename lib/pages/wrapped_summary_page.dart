import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../main.dart';
import '../models/item_model.dart';
import '../services/calculation_service.dart';
import '../services/formatters.dart';

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
    final ceyizProgress =
        ceyizItems.isEmpty ? 0 : calc.completedItems(ceyizItems) / ceyizItems.length;
    final mustHave = controller.items
        .where((item) => item.priority == ItemPriority.mustHave)
        .toList();
    final mustHaveProgress =
        mustHave.isEmpty ? 0 : calc.completedItems(mustHave) / mustHave.length;
    final missingCategory = calc.mostMissingCategory(controller.items);
    final days = calc.daysUntilWedding(controller.settings);
    final cards = [
      'Bu süreçte toplam ${money(calc.totalSpent(controller.items))} harcadın.',
      topCategory == null
          ? 'Henüz en çok harcama yapılan kategori oluşmadı.'
          : 'En çok harcamayı ${topCategory.label} kategorisine yaptın.',
      topItem == null
          ? 'En pahalı alışverişin henüz kaydedilmedi.'
          : 'En pahalı alışverişin: ${topItem.title} - ${money(topItem.actualPrice)}.',
      'Çeyiz hazırlığının %${(ceyizProgress * 100).round()} bölümü tamamlandı.',
      'Olmazsa olmaz ürünlerin %${(mustHaveProgress * 100).round()} hazır.',
      missingCategory == null
          ? 'Eksik kategori hesaplanamadı.'
          : 'En eksik kalan kategori: ${missingCategory.label}.',
      days == null
          ? 'Düğün tarihi eklendiğinde kalan gün kartın burada görünecek.'
          : 'Düğüne $days gün kala hazırlık seviyen: ${calc.scoreMessage(score)}.',
      'Toplam ${controller.items.length} üründen ${calc.completedItems(controller.items)} tanesini tamamladın.',
      'Bu tempoyla ana ihtiyaçlar büyük ölçüde tamamlanabilir.',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hazırlık Özeti'),
        actions: [
          IconButton(
            tooltip: 'Özet metnini paylaş',
            onPressed: () => Share.share(cards.join('\n')),
            icon: const Icon(Icons.ios_share),
          ),
        ],
      ),
      body: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: index.isEven
                      ? const [Color(0xFFE84A7A), Color(0xFF5F6FD9)]
                      : const [Color(0xFF0D9488), Color(0xFFE84A7A)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}/${cards.length}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const Spacer(),
                  Text(
                    cards[index],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: index == cards.length - 1
                        ? () => Share.share(cards.join('\n'))
                        : null,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(
                      index == cards.length - 1
                          ? 'Özet metnini paylaş'
                          : 'Detaylı özet yakında',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
