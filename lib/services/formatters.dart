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
  return double.tryParse(normalized) ?? 0;
}
