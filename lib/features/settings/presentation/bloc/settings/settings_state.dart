import 'package:equatable/equatable.dart';
import 'package:physigest/features/settings/domain/entities/attendance_category.dart';
import 'package:physigest/features/settings/domain/entities/payment_method.dart';
import 'package:physigest/features/settings/domain/entities/dashboard_preferences.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final String userEmail;
  final List<AttendanceCategory> categories;
  final List<PaymentMethod> paymentMethods;
  final DashboardPreferences dashboardPreferences;

  const SettingsLoaded({
    required this.userEmail,
    required this.categories,
    required this.paymentMethods,
    required this.dashboardPreferences,
  });

  SettingsLoaded copyWith({
    String? userEmail,
    List<AttendanceCategory>? categories,
    List<PaymentMethod>? paymentMethods,
    DashboardPreferences? dashboardPreferences,
  }) {
    return SettingsLoaded(
      userEmail: userEmail ?? this.userEmail,
      categories: categories ?? this.categories,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      dashboardPreferences: dashboardPreferences ?? this.dashboardPreferences,
    );
  }

  @override
  List<Object?> get props => [
        userEmail,
        categories,
        paymentMethods,
        dashboardPreferences,
      ];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
