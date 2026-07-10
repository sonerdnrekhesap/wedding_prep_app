import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_prep_app/models/app_settings_model.dart';
import 'package:wedding_prep_app/models/guest_model.dart';
import 'package:wedding_prep_app/models/item_model.dart';
import 'package:wedding_prep_app/services/calculation_service.dart';
import 'package:wedding_prep_app/services/export_service.dart';
import 'package:wedding_prep_app/services/notification_service.dart';

void main() {
  group('CalculationService', () {
    test('handles zero budget without division errors', () {
      final service = CalculationService();
      final items = [_item(actualPrice: 1000)];

      expect(
        service.budgetUsagePercent(const AppSettings(targetBudget: 0), items),
        0,
      );
    });

    test('calculates weighted completion score', () {
      final service = CalculationService();
      final items = [
        _item(priority: ItemPriority.mustHave, isCompleted: true),
        _item(id: '2', priority: ItemPriority.necessary),
      ];

      expect(service.weightedPreparationScore(items), closeTo(62.5, .01));
    });

    test('finds most missing category', () {
      final service = CalculationService();
      final category = service.mostMissingCategory([
        _item(mainCategory: MainCategory.dugun),
        _item(id: '2', mainCategory: MainCategory.dugun, isCompleted: true),
        _item(id: '3', mainCategory: MainCategory.ceyiz),
      ]);

      expect(category, MainCategory.dugun);
    });

    test('finds due soon tasks and upcoming payments', () {
      final service = CalculationService();
      final item = _item(
        dueDate: DateTime.now().add(const Duration(days: 3)),
        paymentDeadline: DateTime.now().add(const Duration(days: 5)),
        contractTotal: 10000,
        depositPaid: 2500,
      );

      expect(service.dueSoonItems([item]), hasLength(1));
      expect(service.upcomingPayments([item]), hasLength(1));
      expect(service.remainingPaymentFor(item), 7500);
    });

    test('creates tasteful progress milestones', () {
      final service = CalculationService();
      final items = [
        for (var i = 0; i < 10; i++)
          _item(id: '$i', isCompleted: true, actualPrice: i == 0 ? 100 : 0),
      ];

      final milestones = service.milestones(
        AppSettings(weddingDate: DateTime.now().add(const Duration(days: 20))),
        items,
        const [],
      );

      expect(milestones, contains('İlk 10 görev tamamlandı'));
      expect(milestones, contains('İlk bütçe kaydı girildi'));
      expect(milestones, contains('Son 30 güne girildi'));
    });
  });

  group('Models', () {
    test('item serialization preserves core fields', () {
      final item = _item(
        actualPrice: 2500,
        affiliateUrl: 'https://example.com',
      );

      final decoded = PrepItem.fromJson(item.toJson());

      expect(decoded.id, item.id);
      expect(decoded.actualPrice, 2500);
      expect(decoded.affiliateUrl, 'https://example.com');
    });

    test('item sanitization prevents negative prices and quantity', () {
      final item = _item(estimatedPrice: -10, actualPrice: -20, quantity: -1);

      final clean = item.sanitized();

      expect(clean.estimatedPrice, 0);
      expect(clean.actualPrice, 0);
      expect(clean.quantity, 1);
    });

    test('guest serialization clamps invalid guest count', () {
      final now = DateTime(2026);
      final guest = Guest(
        id: 'g1',
        name: 'Ayşe',
        side: GuestSide.common,
        guestCount: -3,
        createdAt: now,
        updatedAt: now,
      );

      final decoded = Guest.fromJson(guest.toJson());

      expect(decoded.guestCount, 1);
    });
  });

  group('Notification decisions', () {
    test('does not schedule countdown for past wedding date', () {
      final service = NotificationService();
      final schedule = service.buildSchedule(
        AppSettings(
          notificationsEnabled: true,
          weddingDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        [_item()],
      );

      expect(schedule, isEmpty);
    });

    test('creates budget warning after 80 percent usage', () {
      final service = NotificationService();
      final schedule = service.buildSchedule(
        AppSettings(
          notificationsEnabled: true,
          targetBudget: 1000,
          weddingDate: DateTime.now().add(const Duration(days: 30)),
        ),
        [_item(actualPrice: 850)],
      );

      expect(schedule.any((item) => item.id == 1004), isTrue);
    });
  });

  group('Backup export', () {
    test('exports and parses validated JSON backup', () {
      final service = ExportService();
      final raw = service.buildJsonBackup(
        settings: const AppSettings(targetBudget: 1000),
        items: [_item()],
        guests: const [],
        leads: const [],
      );

      final backup = service.parseJsonBackup(raw);

      expect(backup.settings.targetBudget, 1000);
      expect(backup.items.length, 1);
    });

    test('rejects unsupported backup schema', () {
      final service = ExportService();

      expect(
        () => service.parseJsonBackup('{"schemaVersion":99}'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

PrepItem _item({
  String id = '1',
  MainCategory mainCategory = MainCategory.ceyiz,
  ItemPriority priority = ItemPriority.mustHave,
  bool isCompleted = false,
  double estimatedPrice = 1000,
  double actualPrice = 0,
  String affiliateUrl = '',
  int quantity = 1,
  DateTime? dueDate,
  DateTime? paymentDeadline,
  double contractTotal = 0,
  double depositPaid = 0,
}) {
  final now = DateTime(2026);
  return PrepItem(
    id: id,
    title: 'Buzdolabı',
    mainCategory: mainCategory,
    subCategory: 'Beyaz Eşya',
    priority: priority,
    estimatedPrice: estimatedPrice,
    actualPrice: actualPrice,
    isCompleted: isCompleted,
    affiliateUrl: affiliateUrl,
    quantity: quantity,
    dueDate: dueDate,
    paymentDeadline: paymentDeadline,
    contractTotal: contractTotal,
    depositPaid: depositPaid,
    createdAt: now,
    updatedAt: now,
  );
}
