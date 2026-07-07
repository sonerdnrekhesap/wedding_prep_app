import 'package:flutter/material.dart';

import '../main.dart';
import '../models/item_model.dart';
import '../services/formatters.dart';
import '../widgets/priority_badge.dart';

class PriorityPage extends StatelessWidget {
  const PriorityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = AppScope.of(context)
        .items
        .where((item) => !item.isCompleted)
        .toList()
      ..sort((a, b) => a.priority.sortOrder.compareTo(b.priority.sortOrder));

    return Scaffold(
      appBar: AppBar(title: const Text('Önce Ne Almalıyım?')),
      body: ListView(
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
