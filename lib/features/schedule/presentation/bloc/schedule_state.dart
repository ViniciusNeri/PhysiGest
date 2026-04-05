import 'package:equatable/equatable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

enum ScheduleStatus { initial, loading, success, failure }

enum ScheduleViewMode { day, threeDays, week, month }

class ScheduleState extends Equatable {
  final ScheduleStatus status;
  final ScheduleViewMode viewMode;
  final DateTime selectedDate;
  final List<Appointment> appointments;
  final List<Map<String, dynamic>> availablePatients;
  final List<Map<String, dynamic>> activeCategories;
  final String? errorMessage;
  final String? successMessage;

  const ScheduleState({
    this.status = ScheduleStatus.initial,
    this.viewMode = ScheduleViewMode.week,
    required this.selectedDate,
    this.appointments = const [],
    this.availablePatients = const [],
    this.activeCategories = const [],
    this.errorMessage,
    this.successMessage,
  });

  List<Appointment> get selectedDayAppointments {
    return appointments.where((apt) {
      return apt.startDate.year == selectedDate.year &&
          apt.startDate.month == selectedDate.month &&
          apt.startDate.day == selectedDate.day;
    }).toList();
  }

  ScheduleState copyWith({
    ScheduleStatus? status,
    ScheduleViewMode? viewMode,
    DateTime? selectedDate,
    List<Appointment>? appointments,
    List<Map<String, dynamic>>? availablePatients,
    List<Map<String, dynamic>>? activeCategories,
    String? errorMessage,
    String? successMessage,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      viewMode: viewMode ?? this.viewMode,
      selectedDate: selectedDate ?? this.selectedDate,
      appointments: appointments ?? this.appointments,
      availablePatients: availablePatients ?? this.availablePatients,
      activeCategories: activeCategories ?? this.activeCategories,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    viewMode,
    selectedDate,
    appointments,
    availablePatients,
    activeCategories,
    errorMessage,
    successMessage,
  ];
}
