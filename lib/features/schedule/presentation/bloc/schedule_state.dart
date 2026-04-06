import 'package:equatable/equatable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
import 'package:physigest/features/schedule/domain/models/agenda_lock.dart';

enum ScheduleStatus { initial, loading, success, failure }

enum ScheduleViewMode { day, threeDays, week, month }

class ScheduleState extends Equatable {
  final ScheduleStatus status;
  final ScheduleViewMode viewMode;
  final DateTime selectedDate;
  final List<Appointment> appointments;
  final List<AgendaLock> agendaLocks;
  final List<Map<String, dynamic>> availablePatients;
  final List<Map<String, dynamic>> activeCategories;
  final String? errorMessage;
  final String? successMessage;

  const ScheduleState({
    this.status = ScheduleStatus.initial,
    this.viewMode = ScheduleViewMode.week,
    required this.selectedDate,
    this.appointments = const [],
    this.agendaLocks = const [],
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
    List<AgendaLock>? agendaLocks,
    List<Map<String, dynamic>>? availablePatients,
    List<Map<String, dynamic>>? activeCategories,
    String? errorMessage,
    String? successMessage,
    bool resetSuccess = false,
    bool resetError = false,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      viewMode: viewMode ?? this.viewMode,
      selectedDate: selectedDate ?? this.selectedDate,
      appointments: appointments ?? this.appointments,
      agendaLocks: agendaLocks ?? this.agendaLocks,
      availablePatients: availablePatients ?? this.availablePatients,
      activeCategories: activeCategories ?? this.activeCategories,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
      successMessage: resetSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    viewMode,
    selectedDate,
    appointments,
    agendaLocks,
    availablePatients,
    activeCategories,
    errorMessage,
    successMessage,
  ];
}
