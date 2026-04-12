class Appointment {
  final String id;
  final String patientId;
  final String userId;
  final String title;
  final String description;
  final String date;
  final String status;
  final String? categoryName;
  final String? notes;
  final String createdAt;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    this.categoryName,
    this.notes,
    required this.createdAt,
  });

  // Formata a data para exibição: "05 Mar" e "14:00"
  String get displayDate {
    try {
      final dt = DateTime.parse(date.split('Z')[0]);
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
      final dt = DateTime.parse(date.split('Z')[0]);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'scheduled':
      case 'agendado':
        return 'AGENDADO';
      case 'realizado':
      case 'completed':
        return 'REALIZADO';
      case 'cancelado':
      case 'cancelled':
        return 'CANCELADO';
      case 'falta':
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
      case 'agendado':
        return 'yellow';
      case 'realizado':
      case 'completed':
        return 'teal';
      case 'cancelado':
      case 'cancelled':
      case 'falta':
      case 'no_show':
        return 'red';
      default:
        return 'grey';
    }
  }
}
