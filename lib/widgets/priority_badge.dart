import 'package:flutter/material.dart';

import '../models/item_model.dart';

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final ItemPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      ItemPriority.mustHave => const Color(0xFFE84A7A),
      ItemPriority.necessary => const Color(0xFF5F6FD9),
      ItemPriority.later => const Color(0xFF0D9488),
      ItemPriority.luxury => const Color(0xFFB7791F),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        priority.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
