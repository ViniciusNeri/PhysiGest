import '../entities/auth_user.dart';

abstract class IAuthRepository {
  Future<AuthUser> login(String email, String password);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String password);
  Future<void> logout();
  Future<AuthUser> signUp(String name, String email, String password);
  Future<AuthUser> confirmSignUp(String email, String confirmationCode);
  Future<AuthUser> signInWithGoogle();
  Future<AuthUser> signInWithApple();
}
