import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

enum FinancialStatus { initial, loading, success, failure }

class FinancialState extends Equatable {
  final FinancialStatus status;
  final double faturamentoTotal;
  final double contasReceber;
  final double despesasFixas;
  final double lucroLiquido;
  final List<Transaction> transacoes;
  final Map<String, double> incomeByMethod;
  final Map<String, double> expenseByMethod;
  final Map<int, double> yearlyRevenue;
  final Map<int, double> yearlyExpenses;
  final int selectedMonth;
  final int selectedYear;
  final String? errorMessage;
  final String? successMessage;

  const FinancialState({
    this.status = FinancialStatus.initial,
    this.faturamentoTotal = 0,
    this.contasReceber = 0,
    this.despesasFixas = 0,
    this.lucroLiquido = 0,
    this.transacoes = const [],
    this.incomeByMethod = const {},
    this.expenseByMethod = const {},
    this.yearlyRevenue = const {},
    this.yearlyExpenses = const {},
    this.selectedMonth = 1,
    this.selectedYear = 2024,
    this.errorMessage,
    this.successMessage,
  });

  @override
  List<Object?> get props => [
        status,
        faturamentoTotal,
        contasReceber,
        despesasFixas,
        lucroLiquido,
        transacoes,
        incomeByMethod,
        expenseByMethod,
        yearlyRevenue,
        yearlyExpenses,
        selectedMonth,
        selectedYear,
        errorMessage,
        successMessage,
      ];

  FinancialState copyWith({
    FinancialStatus? status,
    double? faturamentoTotal,
    double? contasReceber,
    double? despesasFixas,
    double? lucroLiquido,
    List<Transaction>? transacoes,
    Map<String, double>? incomeByMethod,
    Map<String, double>? expenseByMethod,
    Map<int, double>? yearlyRevenue,
    Map<int, double>? yearlyExpenses,
    int? selectedMonth,
    int? selectedYear,
    String? errorMessage,
    String? successMessage,
    bool clearMessage = false,
  }) {
    return FinancialState(
      status: status ?? this.status,
      faturamentoTotal: faturamentoTotal ?? this.faturamentoTotal,
      contasReceber: contasReceber ?? this.contasReceber,
      despesasFixas: despesasFixas ?? this.despesasFixas,
      lucroLiquido: lucroLiquido ?? this.lucroLiquido,
      transacoes: transacoes ?? this.transacoes,
      incomeByMethod: incomeByMethod ?? this.incomeByMethod,
      expenseByMethod: expenseByMethod ?? this.expenseByMethod,
      yearlyRevenue: yearlyRevenue ?? this.yearlyRevenue,
      yearlyExpenses: yearlyExpenses ?? this.yearlyExpenses,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      errorMessage: clearMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessage ? null : (successMessage ?? this.successMessage),
    );
  }
}
