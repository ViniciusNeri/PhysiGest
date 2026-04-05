import 'package:equatable/equatable.dart';

class FinancialSummary extends Equatable {
  final double faturamentoTotal;
  final double contasReceber;
  final double despesasFixas;
  final double lucroLiquido;
  final Map<String, double> incomeByMethod;
  final Map<String, double> expenseByMethod;

  const FinancialSummary({
    required this.faturamentoTotal,
    required this.contasReceber,
    required this.despesasFixas,
    required this.lucroLiquido,
    this.incomeByMethod = const {},
    this.expenseByMethod = const {},
  });

  @override
  List<Object?> get props => [
    faturamentoTotal,
    contasReceber,
    despesasFixas,
    lucroLiquido,
    incomeByMethod,
    expenseByMethod,
  ];
}
