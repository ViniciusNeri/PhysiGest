import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import 'package:physigest/core/storage/local_storage.dart';
import 'package:physigest/features/settings/domain/entities/attendance_category.dart';
import 'package:physigest/features/settings/domain/entities/payment_method.dart';
import 'package:physigest/features/settings/domain/entities/dashboard_preferences.dart';
import '../models/settings_models.dart';

abstract class ISettingsRemoteDataSource {
  Future<List<AttendanceCategoryModel>> getCategories();
  Future<AttendanceCategoryModel> createCategory(AttendanceCategory category);
  Future<AttendanceCategoryModel> updateCategory(AttendanceCategory category);
  Future<void> deleteCategory(String id);

  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<PaymentMethodModel> createPaymentMethod(PaymentMethod method);
  Future<PaymentMethodModel> updatePaymentMethod(PaymentMethod method);
  Future<void> deletePaymentMethod(String id);

  Future<void> changePassword(String currentPassword, String newPassword);

  Future<DashboardPreferencesModel> getDashboardPreferences();
  Future<void> updateDashboardPreferences(DashboardPreferences preferences);
}

@LazySingleton(as: ISettingsRemoteDataSource)
class SettingsRemoteDataSource implements ISettingsRemoteDataSource {
  final ApiClient apiClient;
  final LocalStorage localStorage;

  SettingsRemoteDataSource(this.apiClient, this.localStorage);

  @override
  Future<List<AttendanceCategoryModel>> getCategories() async {
    try {
      final user = await localStorage.getUser();
      final userId = user?.id ?? '';
      final response = await apiClient.dio.get('/categories/user/$userId');
      final list = response.data as List<dynamic>;
      return list
          .map((json) => AttendanceCategoryModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Erro ao buscar categorias.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro ao buscar categorias: $e');
    }
  }

  @override
  Future<AttendanceCategoryModel> createCategory(
    AttendanceCategory category,
  ) async {
    try {
      final body = AttendanceCategoryModel(
        id: category.id,
        name: category.name,
        isActive: category.isActive,
      ).toJson();
      final response = await apiClient.dio.post(
        '/categories',
        data: body,
      );
      return AttendanceCategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Erro ao criar categoria.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro ao criar categoria: $e');
    }
  }

  @override
  Future<AttendanceCategoryModel> updateCategory(
    AttendanceCategory category,
  ) async {
    try {
      final body = AttendanceCategoryModel(
        id: category.id,
        name: category.name,
        isActive: category.isActive,
      ).toJson();
      final response = await apiClient.dio.put(
        '/categories/${category.id}',
        data: body,
      );
      return AttendanceCategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Erro ao atualizar categoria.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro ao atualizar categoria: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await apiClient.dio.delete('/categories/$id');
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Erro ao excluir categoria.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro ao excluir categoria: $e');
    }
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final user = await localStorage.getUser();
      final userId = user?.id ?? '';

      final response = await apiClient.dio.get('/payment-methods/user/$userId');
      final list = response.data as List<dynamic>;
      return list.map((json) => PaymentMethodModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Erro ao buscar formas de pagamento.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro ao buscar formas de pagamento: $e');
    }
  }

  @override
  Future<PaymentMethodModel> createPaymentMethod(PaymentMethod method) async {
    try {
      final body = PaymentMethodModel(
        id: method.id,
        name: method.name,
        isActive: method.isActive,
      ).toJson();
      final response = await apiClient.dio.post(
        '/payment-methods',
        data: body,
      );
      return PaymentMethodModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Erro ao criar forma de pagamento.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro ao criar forma de pagamento: $e');
    }
  }

  @override
  Future<PaymentMethodModel> updatePaymentMethod(PaymentMethod method) async {
    try {
      final body = PaymentMethodModel(
        id: method.id,
        name: method.name,
        isActive: method.isActive,
      ).toJson();
      final response = await apiClient.dio.put(
        '/payment-methods/${method.id}',
        data: body,
      );
      return PaymentMethodModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ??
          'Erro ao atualizar forma de pagamento.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro ao atualizar forma de pagamento: $e');
    }
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    try {
      await apiClient.dio.delete('/payment-methods/$id');
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Erro ao excluir forma de pagamento.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro ao excluir forma de pagamento: $e');
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await apiClient.dio.put(
        '/auth/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao alterar senha.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro ao alterar senha: $e');
    }
  }

  @override
  Future<DashboardPreferencesModel> getDashboardPreferences() async {
    try {
      final response = await apiClient.dio.get('/settings');
      final data = response.data;
      if (data is List) {
        if (data.isEmpty) return const DashboardPreferencesModel();
        return DashboardPreferencesModel.fromJson(data.first);
      }
      return DashboardPreferencesModel.fromJson(data);
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ??
          'Erro ao buscar preferências do dashboard.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro ao buscar preferências: $e');
    }
  }

  @override
  Future<void> updateDashboardPreferences(
    DashboardPreferences preferences,
  ) async {
    try {
      final body = DashboardPreferencesModel(
        dashboardTheme: preferences.dashboardTheme,
        showWeeklyAppointments: preferences.showWeeklyAppointments,
        showMonthlyIncome: preferences.showMonthlyIncome,
        showActivePayments: preferences.showActivePayments,
        showNextAppointment: preferences.showNextAppointment,
        categoryControlMode: preferences.categoryControlMode,
      ).toJson();
      await apiClient.dio.put('/settings', data: body);
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ??
          'Erro ao atualizar preferências do dashboard.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro ao atualizar preferências: $e');
    }
  }
}
