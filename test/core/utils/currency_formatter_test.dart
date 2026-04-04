import 'package:flutter_test/flutter_test.dart';
import 'package:physigest/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('Should format double to pt_BR currency string', () {
      expect(CurrencyFormatter.format(0.0), 'R\$\u00A00,00');
      expect(CurrencyFormatter.format(10.5), 'R\$\u00A010,50');
      expect(CurrencyFormatter.format(1000.0), 'R\$\u00A01.000,00');
      expect(CurrencyFormatter.format(1234567.89), 'R\$\u00A01.234.567,89');
    });

    test('Should format double to compact pt_BR currency string', () {
      expect(CurrencyFormatter.formatCompact(1000.0), 'R\$\u00A01.000');
      expect(CurrencyFormatter.formatCompact(1234.56), 'R\$\u00A01.235'); // Arredonda
    });

    test('Should parse pt_BR string to double', () {
      expect(CurrencyFormatter.parse('1.234,56'), 1234.56);
      expect(CurrencyFormatter.parse('R\$ 1.234,56'), 1234.56);
      expect(CurrencyFormatter.parse('1000'), 1000.0);
      expect(CurrencyFormatter.parse('10,50'), 10.5);
    });

    test('Should return null for invalid strings', () {
      expect(CurrencyFormatter.parse('abc'), isNull);
    });
  });
}
