import 'package:equatable/equatable.dart';
import 'package:physigest/features/settings/domain/entities/attendance_category.dart';
import 'package:physigest/features/settings/domain/entities/payment_method.dart';
import 'package:physigest/features/settings/domain/entities/dashboard_preferences.dart';
import 'package:physigest/features/schedule/domain/models/agenda_lock.dart';

abstract class SettingsState extends Equatable {
  final String? successMessage;
  const SettingsState({this.successMessage});

  @override
  List<Object?> get props => [successMessage];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final String userEmail;
  final List<AttendanceCategory> categories;
  final List<PaymentMethod> paymentMethods;
  final DashboardPreferences dashboardPreferences;
  final List<AgendaLock> agendaLocks;

  const SettingsLoaded({
    required this.userEmail,
    required this.categories,
    required this.paymentMethods,
    required this.dashboardPreferences,
    this.agendaLocks = const [],
    super.successMessage,
  });

  SettingsLoaded copyWith({
    String? userEmail,
    List<AttendanceCategory>? categories,
    List<PaymentMethod>? paymentMethods,
    DashboardPreferences? dashboardPreferences,
    List<AgendaLock>? agendaLocks,
    String? successMessage,
    bool clearMessage = false,
  }) {
    return SettingsLoaded(
      userEmail: userEmail ?? this.userEmail,
      categories: categories ?? this.categories,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      dashboardPreferences: dashboardPreferences ?? this.dashboardPreferences,
      agendaLocks: agendaLocks ?? this.agendaLocks,
      successMessage: clearMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    userEmail,
    categories,
    paymentMethods,
    dashboardPreferences,
    agendaLocks,
  ];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
