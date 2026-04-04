import 'package:equatable/equatable.dart';

class PatientActivity extends Equatable {
  final String id;
  final String patientId;
  final String userId;
  final String type;
  final String description;
  final DateTime date;
  final Map<String, dynamic>? metadata;

  const PatientActivity({
    required this.id,
    required this.patientId,
    required this.userId,
    required this.type,
    required this.description,
    required this.date,
    this.metadata,
  });

  String get displayDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else {
      const months = [
        'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
        'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
      ];
      return '${date.day} de ${months[date.month - 1]}';
    }
  }

  @override
  List<Object?> get props => [id, patientId, userId, type, description, date, metadata];
}
