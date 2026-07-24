import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_prep_app/models/app_settings_model.dart';
import 'package:wedding_prep_app/models/guest_model.dart';
import 'package:wedding_prep_app/models/item_model.dart';
import 'package:wedding_prep_app/services/calculation_service.dart';

void main() {
  test('weekly plan prioritizes missing wedding date', () {
    final actions = CalculationService().weeklyPlanActions(
      const AppSettings(),
      const [],
      const [],
    );

    expect(actions.first.type, WeeklyPlanActionType.updateWeddingDate);
  });

  test('weekly plan prioritizes critical missing items near wedding', () {
    final item = PrepItem(
      id: 'item-1',
      title: 'Gelinlik prova',
      mainCategory: MainCategory.dugun,
      subCategory: 'Giyim',
      priority: ItemPriority.mustHave,
      estimatedPrice: 15000,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final actions = CalculationService().weeklyPlanActions(
      AppSettings(weddingDate: DateTime.now().add(const Duration(days: 10))),
      [item],
      const [],
    );

    expect(actions.first.type, WeeklyPlanActionType.completeItem);
    expect(actions.first.item, item);
  });

  test('weekly plan asks to confirm uncertain guests', () {
    final guest = Guest(
      id: 'guest-1',
      name: 'Ayse',
      side: GuestSide.bride,
      status: GuestStatus.uncertain,
      guestCount: 2,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final actions = CalculationService().weeklyPlanActions(
      AppSettings(weddingDate: DateTime.now().add(const Duration(days: 20))),
      const [],
      [guest],
    );

    expect(
      actions
          .any((action) => action.type == WeeklyPlanActionType.confirmGuests),
      isTrue,
    );
  });

  test('weekly plan prioritizes items with upcoming target date', () {
    final item = PrepItem(
      id: 'item-due',
      title: 'Nikah şekeri',
      mainCategory: MainCategory.dugun,
      subCategory: 'Hediye',
      priority: ItemPriority.later,
      purchaseDate: DateTime.now().add(const Duration(days: 2)),
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final actions = CalculationService().weeklyPlanActions(
      AppSettings(weddingDate: DateTime.now().add(const Duration(days: 90))),
      [item],
      const [],
    );

    expect(actions.first.item, item);
    expect(actions.first.subtitle, contains('Hedef alış tarihi'));
  });

  test('weekly plan ignores completed items with target date', () {
    final item = PrepItem(
      id: 'item-done',
      title: 'Kına tepsisi',
      mainCategory: MainCategory.kina,
      subCategory: 'Aksesuar',
      priority: ItemPriority.mustHave,
      isCompleted: true,
      purchaseDate: DateTime.now().add(const Duration(days: 2)),
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final actions = CalculationService().weeklyPlanActions(
      AppSettings(weddingDate: DateTime.now().add(const Duration(days: 90))),
      [item],
      const [],
    );

    expect(actions.any((action) => action.item == item), isFalse);
  });
}
