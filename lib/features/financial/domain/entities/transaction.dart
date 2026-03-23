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

  const Transaction({
    required this.id,
    required this.titulo,
    required this.subtitulo,
    required this.valor,
    required this.isExpense,
    required this.data,
    required this.paymentMethod,
    this.patientId,
  });

  @override
  List<Object?> get props => [id, titulo, subtitulo, valor, isExpense, data, paymentMethod, patientId];
}
