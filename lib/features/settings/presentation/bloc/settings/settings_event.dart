import 'package:equatable/equatable.dart';
import 'package:physigest/features/settings/domain/entities/attendance_category.dart';
import 'package:physigest/features/settings/domain/entities/payment_method.dart';
import 'package:physigest/features/settings/domain/entities/dashboard_preferences.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateDashboardPreferences extends SettingsEvent {
  final DashboardPreferences preferences;

  const UpdateDashboardPreferences(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

class AddAttendanceCategory extends SettingsEvent {
  final String name;

  const AddAttendanceCategory(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateAttendanceCategory extends SettingsEvent {
  final AttendanceCategory category;

  const UpdateAttendanceCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteAttendanceCategory extends SettingsEvent {
  final String id;

  const DeleteAttendanceCategory(this.id);

  @override
  List<Object?> get props => [id];
}

class AddPaymentMethod extends SettingsEvent {
  final String name;

  const AddPaymentMethod(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdatePaymentMethod extends SettingsEvent {
  final PaymentMethod method;

  const UpdatePaymentMethod(this.method);

  @override
  List<Object?> get props => [method];
}

class DeletePaymentMethod extends SettingsEvent {
  final String id;

  const DeletePaymentMethod(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteAgendaLock extends SettingsEvent {
  final String id;

  const DeleteAgendaLock(this.id);

  @override
  List<Object?> get props => [id];
}
