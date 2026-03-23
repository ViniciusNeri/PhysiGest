import 'package:equatable/equatable.dart';

class FinancialSummary extends Equatable {
  final double faturamentoTotal;
  final double contasReceber;
  final double despesasFixas;
  final double lucroLiquido;

  const FinancialSummary({
    required this.faturamentoTotal,
    required this.contasReceber,
    required this.despesasFixas,
    required this.lucroLiquido,
  });

  @override
  List<Object?> get props => [
    faturamentoTotal,
    contasReceber,
    despesasFixas,
    lucroLiquido,
  ];
}
