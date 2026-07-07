import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../services/formatters.dart';
import 'priority_badge.dart';

class ItemTile extends StatelessWidget {
  const ItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onCheckboxChanged,
  });

  final PrepItem item;
  final VoidCallback onTap;
  final ValueChanged<bool?> onCheckboxChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: item.isCompleted,
                onChanged: onCheckboxChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        PriorityBadge(priority: item.priority),
                        Text(
                          'Tahmini: ${money(item.estimatedPrice)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6F6470),
                          ),
                        ),
                        Text(
                          'Harcama: ${money(item.actualPrice)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6F6470),
                          ),
                        ),
                        if (item.note.trim().isNotEmpty)
                          const Icon(
                            Icons.sticky_note_2_outlined,
                            size: 16,
                            color: Color(0xFFE84A7A),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
