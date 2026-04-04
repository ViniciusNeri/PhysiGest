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
    super.categoryName,
    super.notes,
    required super.createdAt,
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
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      title: json['title'] ?? json['patientName'] ?? 'Consulta',
      description: json['description'] ?? '',
      date: json['date'] ?? json['startDate'] ?? '',
      status: normalizedStatus,
      categoryName: json['categoryName'],
      notes: json['notes'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}
