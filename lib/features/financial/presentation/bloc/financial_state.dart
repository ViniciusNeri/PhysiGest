import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

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
  final List<Transaction> transacoes;
  final Map<String, double> incomeByMethod;
  final Map<String, double> expenseByMethod;
  final int selectedMonth;
  final int selectedYear;

  const FinancialLoaded({
    required this.faturamentoTotal,
    required this.contasReceber,
    required this.despesasFixas,
    required this.lucroLiquido,
    required this.transacoes,
    this.incomeByMethod = const {},
    this.expenseByMethod = const {},
    required this.selectedMonth,
    required this.selectedYear,
  });

  @override
  List<Object?> get props => [
    faturamentoTotal,
    contasReceber,
    despesasFixas,
    lucroLiquido,
    transacoes,
    incomeByMethod,
    expenseByMethod,
    selectedMonth,
    selectedYear,
  ];

  FinancialLoaded copyWith({
    double? faturamentoTotal,
    double? contasReceber,
    double? despesasFixas,
    double? lucroLiquido,
    List<Transaction>? transacoes,
    Map<String, double>? incomeByMethod,
    Map<String, double>? expenseByMethod,
    int? selectedMonth,
    int? selectedYear,
  }) {
    return FinancialLoaded(
      faturamentoTotal: faturamentoTotal ?? this.faturamentoTotal,
      contasReceber: contasReceber ?? this.contasReceber,
      despesasFixas: despesasFixas ?? this.despesasFixas,
      lucroLiquido: lucroLiquido ?? this.lucroLiquido,
      transacoes: transacoes ?? this.transacoes,
      incomeByMethod: incomeByMethod ?? this.incomeByMethod,
      expenseByMethod: expenseByMethod ?? this.expenseByMethod,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}

class FinancialError extends FinancialState {
  final String message;
  const FinancialError(this.message);

  @override
  List<Object?> get props => [message];
}
