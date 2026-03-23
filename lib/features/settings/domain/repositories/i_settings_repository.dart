import 'package:physigest/features/settings/domain/entities/attendance_category.dart';
import 'package:physigest/features/settings/domain/entities/payment_method.dart';

abstract class ISettingsRepository {
  Future<List<AttendanceCategory>> getCategories();
  Future<AttendanceCategory> createCategory(AttendanceCategory category);
  Future<AttendanceCategory> updateCategory(AttendanceCategory category);
  Future<void> deleteCategory(String id);

  Future<List<PaymentMethod>> getPaymentMethods();
  Future<PaymentMethod> createPaymentMethod(PaymentMethod method);
  Future<PaymentMethod> updatePaymentMethod(PaymentMethod method);
  Future<void> deletePaymentMethod(String id);

  Future<void> changePassword(String currentPassword, String newPassword);
}
