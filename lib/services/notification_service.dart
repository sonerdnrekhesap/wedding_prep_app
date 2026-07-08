import '../models/app_settings_model.dart';
import '../models/item_model.dart';
import 'calculation_service.dart';

class NotificationService {
  const NotificationService();

  Future<void> configure({required bool enabled}) async {
    // flutter_local_notifications bağlandığında izin ve schedule akışı buraya gelecek.
  }

  List<String> previewMessages(AppSettings settings, List<PrepItem> items) {
    final calc = CalculationService();
    final days = calc.daysUntilWedding(settings);
    final mustHaveMissing = calc.missingMustHaveItems(items).length;
    final missing = calc.missingItems(items);
    return [
      'Bu hafta $missing eksik ürünün kaldı.',
      if (days != null) 'Düğüne $days gün kaldı.',
      if (mustHaveMissing > 0)
        'Olmazsa olmaz listende $mustHaveMissing önemli eksik var.',
    ];
  }
}
