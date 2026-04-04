import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final _compactFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 0,
  );

  /// Formata um valor double para o padrão R$ 1.234,56
  static String format(double value) {
    return _currencyFormat.format(value);
  }

  /// Formata um valor double sem casas decimais (ex: R$ 1.234)
  static String formatCompact(double value) {
    return _compactFormat.format(value);
  }

  /// Extrai o valor double de uma string formatada (ex: "1.234,56" -> 1234.56)
  static double? parse(String value) {
    try {
      final sanitized = value.replaceAll('R\$', '').trim().replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(sanitized);
    } catch (_) {
      return null;
    }
  }
}
