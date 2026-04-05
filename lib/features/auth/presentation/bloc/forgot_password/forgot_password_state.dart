import 'package:equatable/equatable.dart';

enum ForgotPasswordStatus { initial, loading, success, failure, resetSuccess }

class ForgotPasswordState extends Equatable {
  final String email;
  final ForgotPasswordStatus status;
  final String errorMessage;

  const ForgotPasswordState({
    this.email = '',
    this.status = ForgotPasswordStatus.initial,
    this.errorMessage = '',
  });

  bool get isValid => email.isNotEmpty;

  ForgotPasswordState copyWith({
    String? email,
    ForgotPasswordStatus? status,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  ForgotPasswordState copyWithNewPassword({
    final String? newPassword,
    final ForgotPasswordStatus? status,
    final String? errorMessage,
  }) {
    return ForgotPasswordState(
      email: email,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, status, errorMessage];
}
