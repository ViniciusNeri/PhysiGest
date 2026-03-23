import 'package:equatable/equatable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

enum ScheduleStatus { initial, loading, success, failure }

enum ScheduleViewMode { day, week, month }

class ScheduleState extends Equatable {
  final ScheduleStatus status;
  final ScheduleViewMode viewMode;
  final DateTime selectedDate;
  final List<Appointment> appointments;
  final List<String> availablePatients;
  final String? errorMessage;

  const ScheduleState({
    this.status = ScheduleStatus.initial,
    this.viewMode = ScheduleViewMode.week,
    required this.selectedDate,
    this.appointments = const [],
    this.availablePatients = const [],
    this.errorMessage,
  });

  List<Appointment> get selectedDayAppointments {
    return appointments.where((apt) {
      return apt.date.year == selectedDate.year &&
          apt.date.month == selectedDate.month &&
          apt.date.day == selectedDate.day;
    }).toList();
  }

  ScheduleState copyWith({
    ScheduleStatus? status,
    ScheduleViewMode? viewMode,
    DateTime? selectedDate,
    List<Appointment>? appointments,
    List<String>? availablePatients,
    String? errorMessage,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      viewMode: viewMode ?? this.viewMode,
      selectedDate: selectedDate ?? this.selectedDate,
      appointments: appointments ?? this.appointments,
      availablePatients: availablePatients ?? this.availablePatients,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    viewMode,
    selectedDate,
    appointments,
    availablePatients,
    errorMessage,
  ];
}
