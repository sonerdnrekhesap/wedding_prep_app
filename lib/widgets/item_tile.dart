import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/item_model.dart';
import '../services/formatters.dart';
import '../theme/app_colors.dart';
import 'priority_badge.dart';

enum ItemQuickAction {
  price,
  inspirationPhoto,
  productPhoto,
  receiptPhoto,
  note,
  delete,
}

extension ItemQuickActionText on ItemQuickAction {
  String get label => switch (this) {
        ItemQuickAction.price => 'Tutar ekle',
        ItemQuickAction.inspirationPhoto => 'İlham fotoğrafı ekle',
        ItemQuickAction.productPhoto => 'Ürün fotoğrafı ekle',
        ItemQuickAction.receiptPhoto => 'Fatura fotoğrafı ekle',
        ItemQuickAction.note => 'Not ekle',
        ItemQuickAction.delete => 'Sil',
      };

  IconData get icon => switch (this) {
        ItemQuickAction.price => Icons.payments_outlined,
        ItemQuickAction.inspirationPhoto => Icons.lightbulb_outline,
        ItemQuickAction.productPhoto => Icons.photo_outlined,
        ItemQuickAction.receiptPhoto => Icons.receipt_long_outlined,
        ItemQuickAction.note => Icons.sticky_note_2_outlined,
        ItemQuickAction.delete => Icons.delete_outline,
      };
}

class ItemTile extends StatelessWidget {
  const ItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onCheckboxChanged,
    required this.onQuickAction,
  });

  final PrepItem item;
  final VoidCallback onTap;
  final ValueChanged<bool?> onCheckboxChanged;
  final ValueChanged<ItemQuickAction> onQuickAction;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedScale(
                duration: 220.ms,
                scale: item.isCompleted ? 1.08 : 1,
                curve: Curves.easeOutBack,
                child: Checkbox(
                  value: item.isCompleted,
                  onChanged: onCheckboxChanged,
                  activeColor: AppColors.mint,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
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
                          item.subCategory,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                        Text(
                          item.actualPrice > 0
                              ? 'Harcama: ${money(item.actualPrice)}'
                              : 'Tahmini: ${money(item.estimatedPrice)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                        if (item.dueDate != null)
                          _MiniMeta(
                            icon: Icons.event_outlined,
                            text:
                                '${item.dueDate!.day}.${item.dueDate!.month}',
                            color: AppColors.gold,
                          ),
                        if (item.paymentDeadline != null)
                          _MiniMeta(
                            icon: Icons.payments_outlined,
                            text: 'Odeme',
                            color: AppColors.coral,
                          ),
                        if (item.inspirationImagePath != null)
                          const Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: AppColors.gold,
                          ),
                        if (item.productImagePath != null)
                          const Icon(
                            Icons.photo_outlined,
                            size: 16,
                            color: AppColors.mint,
                          ),
                        if (item.receiptImagePath != null)
                          const Icon(
                            Icons.receipt_long_outlined,
                            size: 16,
                            color: AppColors.coral,
                          ),
                        if (item.note.trim().isNotEmpty)
                          const Icon(
                            Icons.sticky_note_2_outlined,
                            size: 16,
                            color: AppColors.rose,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<ItemQuickAction>(
                tooltip: 'Hızlı aksiyonlar',
                onSelected: onQuickAction,
                itemBuilder: (context) => [
                  for (final action in ItemQuickAction.values)
                    PopupMenuItem(
                      value: action,
                      child: Row(
                        children: [
                          Icon(action.icon, size: 18),
                          const SizedBox(width: 10),
                          Expanded(child: Text(action.label)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 260.ms).slideX(begin: 0.03, end: 0);
  }
}

class _MiniMeta extends StatelessWidget {
  const _MiniMeta({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
