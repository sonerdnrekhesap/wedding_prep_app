import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_prep_app/data/seed_items.dart';
import 'package:wedding_prep_app/models/app_settings_model.dart';
import 'package:wedding_prep_app/models/guest_model.dart';
import 'package:wedding_prep_app/models/item_model.dart';
import 'package:wedding_prep_app/services/calculation_service.dart';
import 'package:wedding_prep_app/services/export_service.dart';
import 'package:wedding_prep_app/services/item_query_service.dart';
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

    test('returns empty state friendly values for empty item lists', () {
      final service = CalculationService();

      expect(service.completedItems(const []), 0);
      expect(service.missingItems(const []), 0);
      expect(service.weightedPreparationScore(const []), 0);
      expect(service.nextActionItems(const []), isEmpty);
      expect(service.dueSoonItems(const []), isEmpty);
      expect(service.upcomingPayments(const []), isEmpty);
      expect(service.mostMissingCategory(const []), isNull);
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

    test('finds due soon tasks without completed items', () {
      final service = CalculationService();
      final soon = _item(
        id: 'soon',
        dueDate: DateTime.now().add(const Duration(days: 3)),
      );
      final completed = _item(
        id: 'completed',
        isCompleted: true,
        dueDate: DateTime.now().add(const Duration(days: 2)),
      );
      final later = _item(
        id: 'later',
        dueDate: DateTime.now().add(const Duration(days: 30)),
      );

      expect(service.dueSoonItems([later, completed, soon]), [soon]);
    });

    test('finds upcoming payments and remaining payment amounts', () {
      final service = CalculationService();
      final item = _item(
        paymentDeadline: DateTime.now().add(const Duration(days: 5)),
        contractTotal: 10000,
        depositPaid: 2500,
      );

      expect(service.upcomingPayments([item]), hasLength(1));
      expect(service.remainingPaymentFor(item), 7500);
    });

    test('remaining payment never goes negative', () {
      final service = CalculationService();
      final item = _item(
        contractTotal: 1000,
        totalPaid: 1500,
      );

      expect(service.remainingPaymentFor(item), 0);
    });

    test('creates progress milestones', () {
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

      expect(milestones.length, greaterThanOrEqualTo(3));
      expect(milestones.any((item) => item.contains('10')), isTrue);
      expect(milestones.any((item) => item.contains('butce')), isFalse);
      expect(milestones.any((item) => item.contains('30')), isTrue);
    });
  });

  group('ItemQueryService', () {
    test('filters items by category, subcategory, status, and search', () {
      const service = ItemQueryService();
      final items = [
        _item(id: '1', title: 'Buzdolabi', subCategory: 'Beyaz Esya'),
        _item(
          id: '2',
          title: 'Tencere',
          subCategory: 'Mutfak',
          isCompleted: true,
        ),
        _item(id: '3', title: 'Fotografci', mainCategory: MainCategory.dugun),
      ];

      final result = service.query(
        items: items,
        category: MainCategory.ceyiz,
        subCategory: 'Mutfak',
        filter: ItemFilter.completed,
        searchQuery: 'tencere',
      );

      expect(result.map((item) => item.id), ['2']);
    });

    test('sorts without mutating the original list', () {
      const service = ItemQueryService();
      final original = [
        _item(id: 'low', priority: ItemPriority.later, title: 'B'),
        _item(id: 'high', priority: ItemPriority.mustHave, title: 'A'),
      ];

      final sorted = service.sortItems(original, ItemSort.priority);

      expect(sorted.map((item) => item.id), ['high', 'low']);
      expect(original.map((item) => item.id), ['low', 'high']);
    });

    test('due soon filter ignores past dates', () {
      const service = ItemQueryService();
      final now = DateTime(2026, 7, 10, 12);
      final past = _item(id: 'past', dueDate: DateTime(2026, 7, 9));
      final soon = _item(id: 'soon', dueDate: DateTime(2026, 7, 20));

      final result = service.query(
        items: [past, soon],
        category: MainCategory.ceyiz,
        filter: ItemFilter.dueSoon,
        now: now,
      );

      expect(result.map((item) => item.id), ['soon']);
    });
  });

  group('Models and seed data', () {
    test('item serialization preserves current fields', () {
      final item = _item(
        actualPrice: 2500,
        affiliateUrl: 'https://example.com',
        dueDate: DateTime(2026, 8, 1),
        paymentDeadline: DateTime(2026, 8, 15),
        vendorName: 'Vendor',
        contractTotal: 5000,
        depositPaid: 1000,
      );

      final decoded = PrepItem.fromJson(item.toJson());

      expect(decoded.id, item.id);
      expect(decoded.actualPrice, 2500);
      expect(decoded.affiliateUrl, 'https://example.com');
      expect(decoded.dueDate, DateTime(2026, 8, 1));
      expect(decoded.paymentDeadline, DateTime(2026, 8, 15));
      expect(decoded.vendorName, 'Vendor');
      expect(decoded.contractTotal, 5000);
      expect(decoded.depositPaid, 1000);
    });

    test('older item JSON migrates with safe defaults', () {
      final decoded = PrepItem.fromJson({
        'id': 'legacy',
        'title': 'Legacy item',
        'mainCategory': 'ceyiz',
        'subCategory': 'Mutfak',
        'priority': 'necessary',
        'createdAt': DateTime(2026).toIso8601String(),
        'updatedAt': DateTime(2026).toIso8601String(),
      });

      expect(decoded.affiliateUrl, isEmpty);
      expect(decoded.quantity, 1);
      expect(decoded.dueDate, isNull);
      expect(decoded.vendorName, isEmpty);
      expect(decoded.contractTotal, 0);
      expect(decoded.paymentDeadline, isNull);
    });

    test('item sanitization prevents invalid negative amounts', () {
      final item = _item(
        estimatedPrice: -10,
        actualPrice: -20,
        quantity: -1,
        contractTotal: -30,
        depositPaid: -40,
        totalPaid: -50,
      );

      final clean = item.sanitized();

      expect(clean.estimatedPrice, 0);
      expect(clean.actualPrice, 0);
      expect(clean.quantity, 1);
      expect(clean.contractTotal, 0);
      expect(clean.depositPaid, 0);
      expect(clean.totalPaid, 0);
    });

    test('seed item ids are unique', () {
      final items = buildSeedItems();
      final ids = items.map((item) => item.id).toSet();

      expect(ids.length, items.length);
    });

    test('guest serialization clamps invalid guest count', () {
      final now = DateTime(2026);
      final guest = Guest(
        id: 'g1',
        name: 'Ayse',
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
  String title = 'Buzdolabi',
  MainCategory mainCategory = MainCategory.ceyiz,
  String subCategory = 'Beyaz Esya',
  ItemPriority priority = ItemPriority.mustHave,
  bool isCompleted = false,
  double estimatedPrice = 1000,
  double actualPrice = 0,
  String affiliateUrl = '',
  int quantity = 1,
  DateTime? dueDate,
  DateTime? paymentDeadline,
  String vendorName = '',
  double contractTotal = 0,
  double depositPaid = 0,
  double totalPaid = 0,
}) {
  final now = DateTime(2026);
  return PrepItem(
    id: id,
    title: title,
    mainCategory: mainCategory,
    subCategory: subCategory,
    priority: priority,
    estimatedPrice: estimatedPrice,
    actualPrice: actualPrice,
    isCompleted: isCompleted,
    affiliateUrl: affiliateUrl,
    quantity: quantity,
    dueDate: dueDate,
    vendorName: vendorName,
    contractTotal: contractTotal,
    depositPaid: depositPaid,
    totalPaid: totalPaid,
    paymentDeadline: paymentDeadline,
    createdAt: now,
    updatedAt: now,
  );
}
