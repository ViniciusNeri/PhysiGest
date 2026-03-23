import 'package:physigest/features/schedule/domain/models/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.patientName,
    required super.type,
    required super.date,
    required super.time,
    required super.endTime,
    super.status = 'agendado',
    super.evaluationNote,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id']?.toString() ?? '',
      patientName: json['patientName'] ?? '',
      type: json['type'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      time: json['time'] ?? '00:00',
      endTime: json['endTime'] ?? '00:00',
      status: json['status'] ?? 'agendado',
      evaluationNote: json['evaluationNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'type': type,
      'date': date.toIso8601String(),
      'time': time,
      'endTime': endTime,
      'status': status,
      'evaluationNote': evaluationNote,
    };
  }
}
