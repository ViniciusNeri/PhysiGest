import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final String id;
  final String patientName;
  final String type;
  final DateTime date;
  final String time;
  final String endTime;

  const Appointment({
    required this.id,
    required this.patientName,
    required this.type,
    required this.date,
    required this.time,
    required this.endTime,
  });

  @override
  List<Object?> get props => [id, patientName, type, date, time];
}
