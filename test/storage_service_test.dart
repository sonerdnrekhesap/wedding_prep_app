import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_prep_app/models/app_settings_model.dart';
import 'package:wedding_prep_app/models/guest_model.dart';
import 'package:wedding_prep_app/models/item_model.dart';
import 'package:wedding_prep_app/services/formatters.dart';
import 'package:wedding_prep_app/services/storage_service.dart';

void main() {
  group('StorageService recovery', () {
    test('falls back to seed items when stored item json is corrupt', () async {
      SharedPreferences.setMockInitialValues({'prep_items': 'not-json'});

      final items = await StorageService().loadItems();
      final prefs = await SharedPreferences.getInstance();

      expect(items, isNotEmpty);
      expect(prefs.getString('prep_items'), isNot('not-json'));
      expect(
        prefs.getKeys().where((key) => key.startsWith('prep_items_corrupt_')),
        isNotEmpty,
      );
    });

    test('falls back to empty guests when stored guest json is corrupt',
        () async {
      SharedPreferences.setMockInitialValues({'guests': '{bad'});

      final guests = await StorageService().loadGuests();
      final prefs = await SharedPreferences.getInstance();

      expect(guests, isEmpty);
      expect(prefs.getString('guests'), isNull);
    });

    test('falls back to default settings when stored settings json is corrupt',
        () async {
      SharedPreferences.setMockInitialValues({'settings': '['});

      final settings = await StorageService().loadSettings();

      expect(settings, isA<AppSettings>());
      expect(settings.hasCompletedOnboarding, isFalse);
    });
  });

  group('Model parsing', () {
    test('prep item parser tolerates missing, invalid, and legacy values', () {
      final item = PrepItem.fromJson({
        'id': '',
        'title': '',
        'mainCategory': 'removedCategory',
        'priority': 'removedPriority',
        'estimatedPrice': -50,
        'actualPrice': double.infinity,
        'quantity': 0,
        'createdAt': 'not-a-date',
        'updatedAt': 'not-a-date',
      });

      expect(item.title, 'Isimsiz kalem');
      expect(item.mainCategory, MainCategory.ceyiz);
      expect(item.priority, ItemPriority.necessary);
      expect(item.estimatedPrice, 0);
      expect(item.actualPrice, 0);
      expect(item.quantity, 1);
    });

    test('guest and settings parsers ignore invalid dates', () {
      final guest = Guest.fromJson({
        'id': 'g1',
        'name': 'Ayse',
        'side': 'unknown',
        'status': 'unknown',
        'createdAt': 'bad-date',
        'updatedAt': 'bad-date',
      });
      final settings = AppSettings.fromJson({
        'weddingDate': 'bad-date',
        'targetBudget': -1,
      });

      expect(guest.side, GuestSide.common);
      expect(guest.status, GuestStatus.uncertain);
      expect(settings.weddingDate, isNull);
      expect(settings.targetBudget, 0);
    });
  });

  group('parseMoney', () {
    test('normalizes invalid or unsafe money values', () {
      expect(parseMoney('-100'), 0);
      expect(parseMoney('abc'), 0);
      expect(parseMoney('1.250,50 TL'), 1250.50);
    });
  });
}
