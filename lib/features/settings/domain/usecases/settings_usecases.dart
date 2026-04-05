import 'package:injectable/injectable.dart';
import 'package:physigest/features/settings/domain/entities/attendance_category.dart';
import 'package:physigest/features/settings/domain/entities/payment_method.dart';
import 'package:physigest/features/settings/domain/entities/dashboard_preferences.dart';
import '../repositories/i_settings_repository.dart';

// ==================== CATEGORIES ====================

@lazySingleton
class GetCategoriesUseCase {
  final ISettingsRepository repository;
  GetCategoriesUseCase(this.repository);
  Future<List<AttendanceCategory>> call() => repository.getCategories();
}

@lazySingleton
class CreateCategoryUseCase {
  final ISettingsRepository repository;
  CreateCategoryUseCase(this.repository);
  Future<AttendanceCategory> call(AttendanceCategory category) =>
      repository.createCategory(category);
}

@lazySingleton
class UpdateCategoryUseCase {
  final ISettingsRepository repository;
  UpdateCategoryUseCase(this.repository);
  Future<AttendanceCategory> call(AttendanceCategory category) =>
      repository.updateCategory(category);
}

@lazySingleton
class DeleteCategoryUseCase {
  final ISettingsRepository repository;
  DeleteCategoryUseCase(this.repository);
  Future<void> call(String id) => repository.deleteCategory(id);
}

// ==================== PAYMENT METHODS ====================

@lazySingleton
class GetPaymentMethodsUseCase {
  final ISettingsRepository repository;
  GetPaymentMethodsUseCase(this.repository);
  Future<List<PaymentMethod>> call() => repository.getPaymentMethods();
}

@lazySingleton
class CreatePaymentMethodUseCase {
  final ISettingsRepository repository;
  CreatePaymentMethodUseCase(this.repository);
  Future<PaymentMethod> call(PaymentMethod method) =>
      repository.createPaymentMethod(method);
}

@lazySingleton
class UpdatePaymentMethodUseCase {
  final ISettingsRepository repository;
  UpdatePaymentMethodUseCase(this.repository);
  Future<PaymentMethod> call(PaymentMethod method) =>
      repository.updatePaymentMethod(method);
}

@lazySingleton
class DeletePaymentMethodUseCase {
  final ISettingsRepository repository;
  DeletePaymentMethodUseCase(this.repository);
  Future<void> call(String id) => repository.deletePaymentMethod(id);
}

// ==================== PASSWORD ====================

@lazySingleton
class ChangePasswordUseCase {
  final ISettingsRepository repository;
  ChangePasswordUseCase(this.repository);
  Future<void> call(String currentPassword, String newPassword) =>
      repository.changePassword(currentPassword, newPassword);
}

// ==================== DASHBOARD PREFERENCES ====================

@lazySingleton
class GetDashboardPreferencesUseCase {
  final ISettingsRepository repository;
  GetDashboardPreferencesUseCase(this.repository);
  Future<DashboardPreferences> call() => repository.getDashboardPreferences();
}

@lazySingleton
class UpdateDashboardPreferencesUseCase {
  final ISettingsRepository repository;
  UpdateDashboardPreferencesUseCase(this.repository);
  Future<void> call(DashboardPreferences preferences) =>
      repository.updateDashboardPreferences(preferences);
}
