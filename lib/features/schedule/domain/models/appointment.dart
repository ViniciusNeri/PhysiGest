import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final String id;
  final String patientName;
  final String type;
  final DateTime date;
  final String time;
  final String endTime;
  final String status; // 'agendado', 'realizado', 'falta', 'cancelado'
  final String? evaluationNote;
  final String? patientId;
  final String? description;

  const Appointment({
    required this.id,
    required this.patientName,
    required this.type,
    required this.date,
    required this.time,
    required this.endTime,
    this.status = 'agendado',
    this.evaluationNote,
    this.patientId,
    this.description,
  });

  Appointment copyWith({
    String? id,
    String? patientName,
    String? type,
    DateTime? date,
    String? time,
    String? endTime,
    String? status,
    String? evaluationNote,
    String? patientId,
    String? description,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      evaluationNote: evaluationNote ?? this.evaluationNote,
      patientId: patientId ?? this.patientId,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
    id,
    patientName,
    type,
    date,
    time,
    endTime,
    status,
    evaluationNote,
    patientId,
    description,
  ];
}
