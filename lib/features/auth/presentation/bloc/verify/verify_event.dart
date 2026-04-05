abstract class VerifyEvent {
  const VerifyEvent();
}

class VerifyCodeChanged extends VerifyEvent {
  final String code;
  const VerifyCodeChanged(this.code);
}

class VerifySubmitted extends VerifyEvent {
  final String email;
  const VerifySubmitted(this.email);
}

class VerifyResendCodeRequested extends VerifyEvent {
  final String email;
  const VerifyResendCodeRequested(this.email);
}

class VerifyEmailChanged extends VerifyEvent {
  final String email;
  const VerifyEmailChanged(this.email);
}
