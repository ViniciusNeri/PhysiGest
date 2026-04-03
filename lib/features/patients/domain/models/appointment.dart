class Appointment {
  final String id;
  final String patientId;
  final String userId;
  final String title;
  final String description;
  final String date;
  final String status;
  final String createdAt;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    required this.createdAt,
  });

  // Formata a data para exibição: "05 Mar" e "14:00"
  String get displayDate {
    try {
      final dt = DateTime.parse(date);
      const months = [
        'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
        'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
      ];
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}';
    } catch (_) {
      return date;
    }
  }

  String get displayTime {
    try {
      final dt = DateTime.parse(date);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'AGENDADO';
      case 'completed':
        return 'CONCLUÍDO';
      case 'cancelled':
        return 'CANCELADO';
      case 'no_show':
        return 'FALTA';
      default:
        return status.toUpperCase();
    }
  }

  // Returns (color hint string) for UI
  String get statusColorKey {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'orange';
      case 'completed':
        return 'teal';
      case 'cancelled':
        return 'red';
      case 'no_show':
        return 'red';
      default:
        return 'grey';
    }
  }
}
