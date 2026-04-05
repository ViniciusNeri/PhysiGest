import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String titulo;
  final String subtitulo;
  final double valor;
  final bool isExpense;
  final String data;
  final String paymentMethod;
  final String? patientId;
  final String? patientName;
  final String source; // 'patient' ou 'clinic'
  
  // Novos campos para a API
  final String type; // 'income' ou 'expense'
  final String status; // 'paid' ou 'pending'
  final String category;
  final String? expenseType; // 'fixed' ou 'variable'
  final String description;
  final String? userId;

  const Transaction({
    required this.id,
    required this.titulo,
    required this.subtitulo,
    required this.valor,
    required this.isExpense,
    required this.data,
    required this.paymentMethod,
    this.patientId,
    this.patientName,
    this.source = 'clinic',
    this.type = 'income',
    this.status = 'paid',
    this.category = 'Outros',
    this.expenseType,
    this.description = '',
    this.userId,
  });

  @override
  List<Object?> get props => [
    id,
    titulo,
    subtitulo,
    valor,
    isExpense,
    data,
    paymentMethod,
    patientId,
    patientName,
    source,
    type,
    status,
    category,
    expenseType,
    description,
    userId,
  ];
}
