import 'package:equatable/equatable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

enum PatientBookingStatus { initial, loading, success, failure }

class PatientBookingState extends Equatable {
  final PatientBookingStatus status;
  final List<Appointment> appointments;
  final List<Map<String, dynamic>> categories;
  final DateTime selectedDate;
  final DateTime focusedDate;
  final DateTime? selectedSlot;
  final String? selectedCategoryId;
  final List<DateTime> availableSlots;
  final String? userId;
  final String? errorMessage;
  final String? successMessage;

  const PatientBookingState({
    this.status = PatientBookingStatus.initial,
    this.appointments = const [],
    this.categories = const [],
    required this.selectedDate,
    required this.focusedDate,
    this.selectedSlot,
    this.selectedCategoryId,
    this.availableSlots = const [],
    this.userId,
    this.errorMessage,
    this.successMessage,
  });

  PatientBookingState copyWith({
    PatientBookingStatus? status,
    List<Appointment>? appointments,
    List<Map<String, dynamic>>? categories,
    DateTime? selectedDate,
    DateTime? focusedDate,
    DateTime? selectedSlot,
    String? selectedCategoryId,
    List<DateTime>? availableSlots,
    String? userId,
    String? errorMessage,
    String? successMessage,
  }) {
    return PatientBookingState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      categories: categories ?? this.categories,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDate: focusedDate ?? this.focusedDate,
      selectedSlot: selectedSlot ?? this.selectedSlot,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      availableSlots: availableSlots ?? this.availableSlots,
      userId: userId ?? this.userId,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        appointments,
        categories,
        selectedDate,
        focusedDate,
        selectedSlot,
        selectedCategoryId,
        availableSlots,
        userId,
        errorMessage,
        successMessage,
      ];
}
