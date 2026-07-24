import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_prep_app/models/item_model.dart';
import 'package:wedding_prep_app/services/export_service.dart';

void main() {
  group('ExportService', () {
    test('buildChecklistCsv exports item details for Excel', () {
      final csv = ExportService().buildChecklistCsv([
        PrepItem(
          id: 'item-1',
          title: 'Gelinlik, prova',
          mainCategory: MainCategory.dugun,
          subCategory: 'Giyim',
          priority: ItemPriority.mustHave,
          estimatedPrice: 12000,
          actualPrice: 15000,
          isCompleted: true,
          note: 'Terzi "A" ile gorusuldu',
          shopName: 'Moda Evi',
          brandModel: 'Model 2026',
          quantity: 1,
          completedDate: DateTime(2026, 7, 24),
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ]);

      expect(csv.startsWith('\uFEFF'), isTrue);
      expect(csv, contains('"Kategori","Alt Kategori","Urun"'));
      expect(csv, contains('"Gelinlik, prova"'));
      expect(csv, contains('"Terzi ""A"" ile gorusuldu"'));
      expect(csv, contains('"2026-07-24"'));
    });

    test('buildBudgetCsv summarizes categories', () {
      final csv = ExportService().buildBudgetCsv([
        PrepItem(
          id: 'item-1',
          title: 'Buzdolabi',
          mainCategory: MainCategory.ceyiz,
          subCategory: 'Mutfak',
          priority: ItemPriority.necessary,
          estimatedPrice: 20000,
          actualPrice: 18000,
          isCompleted: true,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
        PrepItem(
          id: 'item-2',
          title: 'Tencere seti',
          mainCategory: MainCategory.ceyiz,
          subCategory: 'Mutfak',
          priority: ItemPriority.mustHave,
          estimatedPrice: 5000,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ]);

      expect(csv.startsWith('\uFEFF'), isTrue);
      expect(csv, contains('"Ceyiz","2","1","1","18000.00","5000.00"'));
    });
  });
}
