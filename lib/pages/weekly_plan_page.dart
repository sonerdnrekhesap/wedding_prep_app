import 'package:flutter/material.dart';

import '../main.dart';
import '../services/calculation_service.dart';
import '../theme/app_colors.dart';
import '../widgets/visual_cards.dart';
import 'budget_page.dart';
import 'guest_list_page.dart';
import 'item_list_page.dart';
import 'priority_page.dart';
import 'settings_page.dart';

class WeeklyPlanPage extends StatelessWidget {
  const WeeklyPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final calc = CalculationService();
    final actions = calc.weeklyPlanActions(
      controller.settings,
      controller.items,
      controller.guests,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Bu Haftanin Plani')),
      body: actions.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: EmptyStateCard(
                icon: Icons.check_circle_outline,
                title: 'Plan sakin gorunuyor',
                message:
                    'Kritik bir eksik yok. Yine de listeleri haftada bir kontrol etmek iyi olur.',
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'En acil ve en etkili adimlar burada. Once ilk uc maddeyi kapat, sonra liste kendini toparlar.',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                for (var i = 0; i < actions.length; i += 1) ...[
                  _WeeklyActionTile(
                    index: i + 1,
                    action: actions[i],
                    onTap: () => _openAction(context, actions[i]),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }

  void _openAction(BuildContext context, WeeklyPlanAction action) {
    switch (action.type) {
      case WeeklyPlanActionType.completeItem:
      case WeeklyPlanActionType.reviewPhotos:
        final category = action.item?.mainCategory;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => category == null
                ? const PriorityPage()
                : ItemListPage(category: category),
          ),
        );
      case WeeklyPlanActionType.reviewBudget:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BudgetPage()),
        );
      case WeeklyPlanActionType.addGuests:
      case WeeklyPlanActionType.confirmGuests:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GuestListPage()),
        );
      case WeeklyPlanActionType.updateWeddingDate:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        );
    }
  }
}

class _WeeklyActionTile extends StatelessWidget {
  const _WeeklyActionTile({
    required this.index,
    required this.action,
    required this.onTap,
  });

  final int index;
  final WeeklyPlanAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _colorFor(action.type).withValues(alpha: 0.16),
          foregroundColor: _colorFor(action.type),
          child: Text(
            '$index',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        title: Text(
          action.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          action.subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Color _colorFor(WeeklyPlanActionType type) {
    return switch (type) {
      WeeklyPlanActionType.completeItem => AppColors.rose,
      WeeklyPlanActionType.reviewBudget => AppColors.gold,
      WeeklyPlanActionType.addGuests => AppColors.mint,
      WeeklyPlanActionType.confirmGuests => AppColors.mint,
      WeeklyPlanActionType.updateWeddingDate => AppColors.roseDeep,
      WeeklyPlanActionType.reviewPhotos => AppColors.roseDeep,
    };
  }
}
