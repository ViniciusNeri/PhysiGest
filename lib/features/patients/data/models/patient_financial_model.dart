import '../../domain/models/patient.dart';

class PatientPaymentModel extends PatientPayment {
  const PatientPaymentModel({
    required super.id,
    required super.patientId,
    required super.userId,
    required super.type,
    required super.category,
    required super.description,
    required super.amount,
    required super.date,
    required super.paymentMethod,
    required super.status,
    super.dueDate,
    super.paymentDate,
    super.notes,
    super.totalSessions = 1,
  });

  factory PatientPaymentModel.fromJson(Map<String, dynamic> json) {
    return PatientPaymentModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? '',
      dueDate: json['dueDate'],
      paymentDate: json['paymentDate'],
      notes: json['notes'],
      totalSessions: json['totalSessions'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'category': category,
      'description': description,
      'amount': amount,
      'date': date,
      'paymentMethod': paymentMethod,
      'status': status,
      'dueDate': dueDate,
      'paymentDate': paymentDate,
      'notes': notes,
      'totalSessions': totalSessions,
    };
  }
}

class PatientFinancialSummaryModel extends PatientFinancialSummary {
  const PatientFinancialSummaryModel({
    super.outstandingBalance = 0,
    super.totalSessions = 0,
    super.totalPaidAmount = 0,
    super.payments = const [],
  });

  factory PatientFinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    final paymentsList = (json['payments'] as List<dynamic>? ?? [])
        .map((p) => PatientPaymentModel.fromJson(p))
        .toList();

    return PatientFinancialSummaryModel(
      outstandingBalance: (json['outstandingBalance'] as num?)?.toDouble() ?? 0.0,
      totalSessions: json['totalSessions'] as int? ?? 0,
      totalPaidAmount: (json['totalPaidAmount'] as num?)?.toDouble() ?? 0.0,
      payments: paymentsList,
    );
  }
}
