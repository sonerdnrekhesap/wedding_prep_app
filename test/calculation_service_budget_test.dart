import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_prep_app/models/app_settings_model.dart';
import 'package:wedding_prep_app/models/item_model.dart';
import 'package:wedding_prep_app/services/calculation_service.dart';

void main() {
  group('CalculationService budgetAdvice', () {
    test('asks for target budget when missing', () {
      final advice = CalculationService().budgetAdvice(
        const AppSettings(),
        const [],
      );

      expect(advice.level, BudgetAdviceLevel.setup);
    });

    test('warns when spending exceeds target budget', () {
      final advice = CalculationService().budgetAdvice(
        const AppSettings(targetBudget: 1000),
        [
          _item(actualPrice: 1200),
        ],
      );

      expect(advice.level, BudgetAdviceLevel.danger);
    });

    test('warns when usage is close to target budget', () {
      final advice = CalculationService().budgetAdvice(
        const AppSettings(targetBudget: 1000),
        [
          _item(actualPrice: 900),
        ],
      );

      expect(advice.level, BudgetAdviceLevel.watch);
    });

    test('warns when next missing estimate exceeds remaining budget', () {
      final advice = CalculationService().budgetAdvice(
        const AppSettings(targetBudget: 1000),
        [
          _item(actualPrice: 200, isCompleted: true),
          _item(title: 'Salon kapora', estimatedPrice: 900),
        ],
      );

      expect(advice.level, BudgetAdviceLevel.watch);
      expect(advice.message, contains('Salon kapora'));
    });

    test('stays calm when budget has room', () {
      final advice = CalculationService().budgetAdvice(
        const AppSettings(targetBudget: 1000),
        [
          _item(actualPrice: 200, isCompleted: true),
          _item(estimatedPrice: 300),
        ],
      );

      expect(advice.level, BudgetAdviceLevel.calm);
    });
  });
}

PrepItem _item({
  String title = 'Kalem',
  double estimatedPrice = 0,
  double actualPrice = 0,
  bool isCompleted = false,
}) {
  return PrepItem(
    id: '$title-$estimatedPrice-$actualPrice-$isCompleted',
    title: title,
    mainCategory: MainCategory.dugun,
    subCategory: 'Genel',
    priority: ItemPriority.necessary,
    estimatedPrice: estimatedPrice,
    actualPrice: actualPrice,
    isCompleted: isCompleted,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}
