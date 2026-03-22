import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure, authenticated }

class LoginState extends Equatable {
  final String email;
  final String password;
  final LoginStatus status;
  final String errorMessage;
  final String? token;  

  const LoginState({
    this.email = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage = '',
    this.token = null,
  });

  bool get isValid => email.isNotEmpty && password.isNotEmpty;

  LoginState copyWith({
    String? email,
    String? password,
    LoginStatus? status,
    String? errorMessage,
    String? token,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [email, password, status, errorMessage, token];
}
