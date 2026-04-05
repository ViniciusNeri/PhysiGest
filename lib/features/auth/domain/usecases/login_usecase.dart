import 'package:injectable/injectable.dart';
import '../entities/auth_user.dart';
import '../repositories/i_auth_repository.dart';

@lazySingleton
class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthUser> call(String email, String password) async {
    return await repository.login(email, password);
  }
}

@lazySingleton
class ForgotPasswordUseCase {
  final IAuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<void> call(String email) async {
    return await repository.forgotPassword(email);
  }
}

@lazySingleton
class ResetPasswordUseCase {
  final IAuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> call(String token, String password) async {
    return await repository.resetPassword(token, password);
  }
}

@lazySingleton
class LogoutUseCase {
  final IAuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() async {
    return await repository.logout();
  }
}

@lazySingleton
class SignUpUseCase {
  final IAuthRepository repository;

  SignUpUseCase(this.repository);

  Future<AuthUser> call(String name, String email, String password) async {
    return await repository.signUp(name, email, password);
  }
}

@lazySingleton
class ConfirmSignUpUseCase {
  final IAuthRepository repository;

  ConfirmSignUpUseCase(this.repository);

  Future<AuthUser> call(String email, String confirmationCode) async {
    return await repository.confirmSignUp(email, confirmationCode);
  }
}

@lazySingleton
class SignInWithGoogleUseCase {
  final IAuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<AuthUser> call() async {
    return await repository.signInWithGoogle();
  }
}

@lazySingleton
class SignInWithAppleUseCase {
  final IAuthRepository repository;

  SignInWithAppleUseCase(this.repository);

  Future<AuthUser> call() async {
    return await repository.signInWithApple();
  }
}
