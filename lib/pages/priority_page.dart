import 'package:flutter/material.dart';

import '../main.dart';
import '../models/item_model.dart';
import '../services/formatters.dart';
import '../widgets/priority_badge.dart';
import '../widgets/visual_cards.dart';

class PriorityPage extends StatelessWidget {
  const PriorityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = AppScope.of(context)
        .items
        .where((item) => !item.isCompleted)
        .toList()
      ..sort((a, b) {
        final priority = a.priority.sortOrder.compareTo(b.priority.sortOrder);
        if (priority != 0) return priority;
        return b.estimatedPrice.compareTo(a.estimatedPrice);
      });

    return Scaffold(
      appBar: AppBar(title: const Text('Önce Ne Almalıyım?')),
      body: items.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: EmptyStateCard(
                icon: Icons.check_circle_outline,
                title: 'Kritik eksik görünmüyor',
                message:
                    'Güzel gidiyorsun. İstersen detay listelerini kontrol et.',
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Önce olmazsa olmazları, sonra pahalı ve gerekli parçaları kapat. Bu sıralama bütçeyi ve zamanı daha rahat yönetir.',
                  style: TextStyle(color: Color(0xFF7B6B72)),
                ),
                const SizedBox(height: 14),
                for (final priority in ItemPriority.values)
                  _PrioritySection(
                    priority: priority,
                    items: items
                        .where((item) => item.priority == priority)
                        .toList(growable: false),
                  ),
              ],
            ),
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
              Text(
                priority == ItemPriority.mustHave
                    ? 'Olmazsa olmazlar tamam.'
                    : 'Bu bölümde eksik yok.',
              )
            else
              for (final item in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${item.subCategory} / ${money(item.estimatedPrice)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    item.mainCategory.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
