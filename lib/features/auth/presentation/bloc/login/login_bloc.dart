import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:physigest/core/storage/local_storage.dart';
import 'package:physigest/core/di/injection.dart';

import '../../../domain/usecases/login_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;

  LoginBloc(this._loginUseCase) : super(const LoginState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<GoogleLoginPressed>(_onGoogleLoginPressed);
  }

  void _onEmailChanged(EmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email, status: LoginStatus.initial));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(password: event.password, status: LoginStatus.initial));
  }

  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isValid) return;

    emit(state.copyWith(status: LoginStatus.loading));
    try {
      final user = await _loginUseCase(state.email, state.password);
      await getIt<LocalStorage>().saveToken(user.token);
      await getIt<LocalStorage>().saveUser(user);
      emit(
        state.copyWith(status: LoginStatus.authenticated, token: user.token),
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: msg));
    }
  }

  Future<void> _onGoogleLoginPressed(
    GoogleLoginPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      // Mocked delay for google auth
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Erro no login com Google',
        ),
      );
    }
  }

  // Future<void> _onAppleLoginPressed(
  //   AppleLoginPressed event,
  //   Emitter<LoginState> emit,
  // ) async {
  //   emit(state.copyWith(status: LoginStatus.loading));
  //   try {
  //     // Mocked delay for apple auth
  //     await Future.delayed(const Duration(seconds: 2));
  //     emit(state.copyWith(status: LoginStatus.success));
  //   } catch (e) {
  //     emit(state.copyWith(status: LoginStatus.failure, errorMessage: 'Erro no login com Apple'));
  //   }
  // }

  // Future<void> _onForgotPasswordPressed(
  //   ForgotPasswordPressed event,
  //   Emitter<LoginState> emit,
  // ) async {
  //   emit(state.copyWith(status: LoginStatus.loading));
  //   try {
  //     await _forgotPasswordUseCase(state.email);
  //     emit(state.copyWith(status: LoginStatus.success));
  //   } catch (e) {
  //     emit(state.copyWith(status: LoginStatus.failure, errorMessage: 'Erro ao redefinir senha'));
  //   }
  // }
}
