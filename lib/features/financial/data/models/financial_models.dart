import '../../domain/entities/transaction.dart';
import '../../domain/entities/financial_summary.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.titulo,
    required super.subtitulo,
    required super.valor,
    required super.isExpense,
    required super.data,
    required super.paymentMethod,
    super.patientId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo'] ?? json['title'] ?? '',
      subtitulo: json['subtitulo'] ?? json['subtitle'] ?? '',
      valor: (json['valor'] ?? json['amount'] as num?)?.toDouble() ?? 0.0,
      isExpense: json['isExpense'] as bool? ?? false,
      data: json['data'] ?? json['date'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      patientId: json['patientId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'subtitulo': subtitulo,
      'valor': valor,
      'isExpense': isExpense,
      'data': data,
      'paymentMethod': paymentMethod,
      'patientId': patientId,
    };
  }
}

class FinancialSummaryModel extends FinancialSummary {
  const FinancialSummaryModel({
    required super.faturamentoTotal,
    required super.contasReceber,
    required super.despesasFixas,
    required super.lucroLiquido,
  });

  factory FinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    return FinancialSummaryModel(
      faturamentoTotal:
          (json['faturamentoTotal'] ?? json['totalRevenue'] as num?)
              ?.toDouble() ??
          0.0,
      contasReceber:
          (json['contasReceber'] ?? json['pendingPayments'] as num?)
              ?.toDouble() ??
          0.0,
      despesasFixas:
          (json['despesasFixas'] ?? json['fixedExpenses'] as num?)
              ?.toDouble() ??
          0.0,
      lucroLiquido:
          (json['lucroLiquido'] ?? json['netProfit'] as num?)?.toDouble() ??
          0.0,
    );
  }
}
