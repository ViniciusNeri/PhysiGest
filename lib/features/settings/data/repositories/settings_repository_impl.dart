import 'package:injectable/injectable.dart';
import 'package:physigest/features/settings/domain/entities/attendance_category.dart';
import 'package:physigest/features/settings/domain/entities/payment_method.dart';
import 'package:physigest/features/settings/domain/entities/dashboard_preferences.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

@LazySingleton(as: ISettingsRepository)
class SettingsRepositoryImpl implements ISettingsRepository {
  final ISettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AttendanceCategory>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<AttendanceCategory> createCategory(AttendanceCategory category) async {
    return await remoteDataSource.createCategory(category);
  }

  @override
  Future<AttendanceCategory> updateCategory(AttendanceCategory category) async {
    return await remoteDataSource.updateCategory(category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    return await remoteDataSource.deleteCategory(id);
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods() async {
    return await remoteDataSource.getPaymentMethods();
  }

  @override
  Future<PaymentMethod> createPaymentMethod(PaymentMethod method) async {
    return await remoteDataSource.createPaymentMethod(method);
  }

  @override
  Future<PaymentMethod> updatePaymentMethod(PaymentMethod method) async {
    return await remoteDataSource.updatePaymentMethod(method);
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    return await remoteDataSource.deletePaymentMethod(id);
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    return await remoteDataSource.changePassword(currentPassword, newPassword);
  }

  @override
  Future<DashboardPreferences> getDashboardPreferences() async {
    return await remoteDataSource.getDashboardPreferences();
  }

  @override
  Future<void> updateDashboardPreferences(
    DashboardPreferences preferences,
  ) async {
    return await remoteDataSource.updateDashboardPreferences(preferences);
  }
}
