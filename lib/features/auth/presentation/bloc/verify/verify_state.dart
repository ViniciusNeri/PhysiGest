enum VerifyStatus { initial, loading, success, failure }

class VerifyState {
  final String email;
  final String code;
  final VerifyStatus status;
  final String errorMessage;

  VerifyState({
    this.email = '',
    this.code = '',
    this.status = VerifyStatus.initial,
    this.errorMessage = '',
  });

  bool get isCodeValid => code.length == 6;

  VerifyState copyWith({
    String? email,
    String? code,
    VerifyStatus? status,
    String? errorMessage,
  }) {
    return VerifyState(
      email: email ?? this.email,
      code: code ?? this.code,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
