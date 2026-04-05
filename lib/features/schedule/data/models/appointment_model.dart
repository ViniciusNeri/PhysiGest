import 'package:physigest/features/schedule/domain/models/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.patientName,
    required super.startDate,
    required super.endDate,
    super.patientId,
    super.userId,
    super.categoryId,
    super.categoryName,
    super.status = 'scheduled',
    super.description,
    super.notes,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    String rawStatus = (json['status'] ?? 'scheduled').toString().toLowerCase();
    String normalizedStatus;
    switch (rawStatus) {
      case 'agendado':
        normalizedStatus = 'scheduled';
        break;
      case 'realizado':
        normalizedStatus = 'completed';
        break;
      case 'cancelado':
        normalizedStatus = 'cancelled';
        break;
      case 'falta':
        normalizedStatus = 'no_show';
        break;
      default:
        normalizedStatus = rawStatus;
    }

    return AppointmentModel(
      id: json['id']?.toString() ?? '',
      patientName: json['patientName'] ?? 'Paciente Não Informado',
      patientId: json['patientId'],
      userId: json['userId'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate']).toLocal()
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate']).toLocal()
          : DateTime.now().add(const Duration(hours: 1)),
      status: normalizedStatus,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'patientId': patientId,
      'userId': userId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      'status': status,
      'description': description,
      'notes': notes,
    };
  }
}
