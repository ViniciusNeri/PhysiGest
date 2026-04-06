import 'package:equatable/equatable.dart';

class AgendaLock extends Equatable {
  final String id;
  final String userId;
  final String type; // 'partial' | 'total'
  final DateTime? date;
  final List<DateTime>? dates;
  final String? startTime;
  final String? endTime;
  final String? description;

  const AgendaLock({
    required this.id,
    required this.userId,
    required this.type,
    this.date,
    this.dates,
    this.startTime,
    this.endTime,
    this.description,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        date,
        dates,
        startTime,
        endTime,
        description,
      ];
}
