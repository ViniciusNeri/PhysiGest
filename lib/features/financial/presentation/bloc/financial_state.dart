import 'package:equatable/equatable.dart';

abstract class FinancialState extends Equatable {
  const FinancialState();

  @override
  List<Object?> get props => [];
}

class FinancialLoading extends FinancialState {}

class FinancialLoaded extends FinancialState {
  final double faturamentoTotal;
  final double contasReceber;
  final double despesasFixas;
  final double lucroLiquido;
  final List<Map<String, dynamic>> transacoes;

  const FinancialLoaded({
    required this.faturamentoTotal,
    required this.contasReceber,
    required this.despesasFixas,
    required this.lucroLiquido,
    required this.transacoes,
  });

  @override
  List<Object?> get props => [faturamentoTotal, contasReceber, despesasFixas, lucroLiquido, transacoes];
}

class FinancialError extends FinancialState {
  final String message;
  const FinancialError(this.message);

  @override
  List<Object?> get props => [message];
}