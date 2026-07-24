import 'package:intl/intl.dart';

final _moneyFormat = NumberFormat.currency(
  locale: 'tr_TR',
  symbol: 'TL',
  decimalDigits: 0,
);

String money(double value) => _moneyFormat.format(value);

double parseMoney(String value) {
  final normalized = value
      .replaceAll('TL', '')
      .replaceAll('.', '')
      .replaceAll(',', '.')
      .trim();
  final parsed = double.tryParse(normalized);
  if (parsed == null || parsed.isNaN || parsed.isInfinite || parsed < 0) {
    return 0;
  }
  return parsed.clamp(0, 999999999).toDouble();
}
