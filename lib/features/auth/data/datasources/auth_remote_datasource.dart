import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_user_model.dart';

abstract class IAuthRemoteDataSource {
  Future<AuthUserModel> login(String email, String password);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String password);
  Future<void> logout();
  Future<AuthUserModel> signUp(String name, String email, String password);
  Future<AuthUserModel> confirmSignUp(String email, String confirmationCode);
  Future<AuthUserModel> signInWithGoogle();
  Future<AuthUserModel> signInWithApple();
}

@LazySingleton(as: IAuthRemoteDataSource)
class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  @override
  Future<AuthUserModel> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/sessions',
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthUserModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro de rede ou servidor ao realizar login.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido na tentativa de autenticação: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await apiClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao solicitar redefinição de senha.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido na tentativa de redefinir senha: $e');
    }
  }

  @override
  Future<void> resetPassword(String token, String password) async {
    try {
      await apiClient.dio.post(
        '/auth/reset-password',
        data: {'token': token, 'password': password},
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao redefinir senha.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido na tentativa de redefinir senha: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.dio.post('/auth/logout');
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao realizar logout.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido na tentativa de logout: $e');
    }
  }

  @override
  Future<AuthUserModel> signUp(String name, String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/signup',
        data: {'name': name, 'email': email, 'password': password},
      );
      return AuthUserModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao registrar novo usuário.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido na tentativa de registro: $e');
    }
  }

  @override
  Future<AuthUserModel> confirmSignUp(String email, String confirmationCode) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/signup/confirm',
        data: {'email': email, 'code': confirmationCode},
      );
      return AuthUserModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao confirmar registro.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido na tentativa de confirmação: $e');
    }
  }

  @override
  Future<AuthUserModel> signInWithGoogle() async {
    // Implementação de login com Google (integração com Firebase/Google Sign-In)
    // Por enquanto, retorna um erro genérico ou implemente a lógica necessária
    throw UnimplementedError('Login com Google não implementado');
  }

  @override
  Future<AuthUserModel> signInWithApple() async {
    // Implementação de login com Apple (integração com Firebase/Apple Sign-In)
    // Por enquanto, retorna um erro genérico ou implemente a lógica necessária
    throw UnimplementedError('Login com Apple não implementado');
  }
}
