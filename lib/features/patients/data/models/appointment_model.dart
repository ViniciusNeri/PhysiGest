import '../../domain/models/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.patientId,
    required super.userId,
    required super.title,
    required super.description,
    required super.date,
    required super.status,
    required super.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? json['_id'] ?? '',
      patientId: json['patientId'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? 'scheduled',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
