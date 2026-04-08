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
    super.patientName,
    super.source = 'clinic',
    super.type,
    super.status,
    super.category = 'Outros',
    super.expenseType,
    super.description = '',
    super.userId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?)?.toDouble() ?? 0.0;
    final type = json['type'] ?? 'income';
    final isExpense = type == 'expense';
    
    return TransactionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      titulo: (json['patientName'] != null && json['patientName'].toString().isNotEmpty)
          ? json['patientName'].toString()
          : (json['description'] != null && json['description'].toString().isNotEmpty)
              ? json['description'].toString()
              : 'Lançamento',
      subtitulo: _formatSubtitulo(
        json['category'] ?? (json['type'] == 'expense' ? 'Despesa' : 'Receita'),
        json['paymentMethod'],
      ),
      valor: amount,
      isExpense: isExpense,
      data: json['date'] != null 
          ? json['date'].toString().split('Z')[0] 
          : '',
      paymentMethod: json['paymentMethod'] ?? '',
      patientId: json['patientId']?.toString(),
      patientName: json['patientName'],
      source: json['source'] ?? 'clinic',
      type: type,
      status: json['status'] ?? 'paid',
      category: json['category'] ?? 'Outros',
      expenseType: json['expenseType'],
      description: json['description'] ?? '',
      userId: json['userId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'status': status,
      'amount': valor,
      'date': data,
      'description': description.isEmpty ? titulo : description,
      'category': category,
      if (expenseType != null) 'expenseType': expenseType,
      'paymentMethod': _mapPaymentMethodToApi(paymentMethod),
      'userId': userId,
      if (patientId != null && patientId!.isNotEmpty) 'patientId': patientId,
    };
  }

  static String _mapPaymentMethodToApi(String method) {
    switch (method.toLowerCase().trim()) {
      case 'pix': return 'pix';
      case 'cartão de crédito':
      case 'crédito': return 'credit_card';
      case 'cartão de débito':
      case 'débito': return 'debit_card';
      case 'dinheiro': return 'cash';
      case 'transferência': return 'bank_transfer';
      case 'boleto': return 'boleto';
      default: return 'cash';
    }
  }
  static String _formatSubtitulo(String category, dynamic paymentMethod) {
    final methodStr = paymentMethod?.toString() ?? '';
    if (methodStr.isEmpty) return category;
    return '$category ($methodStr)';
  }
}

class FinancialSummaryModel extends FinancialSummary {
  const FinancialSummaryModel({
    required super.faturamentoTotal,
    required super.contasReceber,
    required super.despesasFixas,
    required super.lucroLiquido,
    super.incomeByMethod = const {},
    super.expenseByMethod = const {},
    super.yearlyRevenue = const {},
    super.yearlyExpenses = const {},
  });

  factory FinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    Map<String, double> parseMethodMap(Map<String, dynamic>? data) {
      if (data == null) return {};
      return data.map((key, value) => MapEntry(key, (value as num).toDouble()));
    }

    Map<int, double> parseYearlyMap(Map<String, dynamic>? data) {
      if (data == null) return {};
      return data.map((key, value) => MapEntry(int.parse(key), (value as num).toDouble()));
    }

    return FinancialSummaryModel(
      faturamentoTotal: (json['monthlyTotal'] as num?)?.toDouble() ?? 0.0,
      contasReceber: (json['pendingTotal'] as num?)?.toDouble() ?? 0.0,
      despesasFixas: ((json['totalExpenses'] ?? 0.0) as num).toDouble(),
      lucroLiquido: (json['netProfit'] as num?)?.toDouble() ?? 0.0,
      incomeByMethod: parseMethodMap(json['incomeByMethod']),
      expenseByMethod: parseMethodMap(json['expenseByMethod']),
      yearlyRevenue: parseYearlyMap(json['yearlyRevenue']),
      yearlyExpenses: parseYearlyMap(json['yearlyExpenses']),
    );
  }
}
