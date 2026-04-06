import '../../domain/models/agenda_lock.dart';

class AgendaLockModel extends AgendaLock {
  const AgendaLockModel({
    required super.id,
    required super.userId,
    required super.type,
    super.date,
    super.dates,
    super.startTime,
    super.endTime,
    super.description,
  });

  factory AgendaLockModel.fromJson(Map<String, dynamic> json) {
    return AgendaLockModel(
      id: (json['id'] ?? json['_id'] ?? json['userId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      type: (json['type'] ?? 'partial').toString(),
      date: json['date'] != null ? DateTime.parse(json['date'].toString()).toLocal() : null,
      dates: json['dates'] is List
          ? (json['dates'] as List)
              .map((d) => DateTime.parse(d.toString()).toLocal())
              .toList()
          : null,
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'userId': userId,
      'type': type,
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
    };

    if (dates != null && dates!.isNotEmpty) {
      data['dates'] = dates!.map((d) => d.toIso8601String().split('T')[0]).toList();
    } else if (date != null) {
      data['date'] = date!.toIso8601String();
    }

    return data;
  }
}
