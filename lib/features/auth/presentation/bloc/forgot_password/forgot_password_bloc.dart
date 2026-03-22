import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/login_usecase.dart';

import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

@injectable
class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  ForgotPasswordBloc(this._forgotPasswordUseCase, this._resetPasswordUseCase) : super(const ForgotPasswordState()) {
    on<ForgotPasswordEmailChanged>(_onEmailChanged);
    on<ForgotPasswordSubmitted>(_onSubmitted);
    on<NewPasswordSubmitted>(_onNewPasswordSubmitted);  
  }

  void _onEmailChanged(ForgotPasswordEmailChanged event, Emitter<ForgotPasswordState> emit) {
    emit(state.copyWith(email: event.email, status: ForgotPasswordStatus.initial));
  }

  Future<void> _onSubmitted(ForgotPasswordSubmitted event, Emitter<ForgotPasswordState> emit) async {
    if (!state.isValid) return;

    emit(state.copyWith(status: ForgotPasswordStatus.loading));
    try {
      await _forgotPasswordUseCase(state.email);
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    } catch (e) {
      emit(state.copyWith(status: ForgotPasswordStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onNewPasswordSubmitted(NewPasswordSubmitted event, Emitter<ForgotPasswordState> emit) async {
    if (event.newPassword.isEmpty) return;

    emit(state.copyWith(status: ForgotPasswordStatus.loading));
    try {
      await _resetPasswordUseCase(event.token, event.newPassword);
      emit(state.copyWith(status: ForgotPasswordStatus.resetSuccess));
    } catch (e) {
      emit(state.copyWith(status: ForgotPasswordStatus.failure, errorMessage: e.toString()));
    }
  }
}
