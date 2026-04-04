import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final String id;
  final String patientName;
  final String? patientId;
  final String? userId;
  final String? categoryId;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'scheduled', 'completed', 'cancelled', 'no_show'
  final String? description;
  final String? notes;

  const Appointment({
    required this.id,
    required this.patientName,
    required this.startDate,
    required this.endDate,
    this.patientId,
    this.userId,
    this.categoryId,
    this.status = 'scheduled',
    this.description,
    this.notes,
  });

  Appointment copyWith({
    String? id,
    String? patientName,
    String? patientId,
    String? userId,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? description,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      patientId: patientId ?? this.patientId,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      description: description ?? this.description,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientName,
        patientId,
        userId,
        categoryId,
        startDate,
        endDate,
        status,
        description,
        notes,
      ];
}
