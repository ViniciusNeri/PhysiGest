import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:physigest/features/auth/domain/usecases/login_usecase.dart';
import 'verify_event.dart';
import 'verify_state.dart';

@injectable
class VerifyBloc extends Bloc<VerifyEvent, VerifyState> {
  final ConfirmSignUpUseCase _confirmSignUpUseCase;

  VerifyBloc(this._confirmSignUpUseCase) : super(VerifyState()) {
    on<VerifyEmailChanged>((event, emit) {
      emit(state.copyWith(email: event.email, status: VerifyStatus.initial));
    });

    on<VerifyCodeChanged>((event, emit) {
      emit(state.copyWith(code: event.code, status: VerifyStatus.initial));
    });

    on<VerifySubmitted>((event, emit) async {
      if (!state.isCodeValid) return;

      emit(state.copyWith(status: VerifyStatus.loading));
      try {
        final user = await _confirmSignUpUseCase(event.email, state.code);
        emit(state.copyWith(status: VerifyStatus.success));
      } catch (e) {
        emit(
          state.copyWith(
            status: VerifyStatus.failure,
            errorMessage: 'Código inválido ou expirado.',
          ),
        );
      }
    });

    on<VerifyResendCodeRequested>((event, emit) async {
      emit(state.copyWith(status: VerifyStatus.loading));
      try {
        // Lógica para chamar sua API de reenvio no Node.js
        await Future.delayed(const Duration(seconds: 2)); // Simulação
        emit(state.copyWith(status: VerifyStatus.success));
      } catch (e) {
        emit(
          state.copyWith(
            status: VerifyStatus.failure,
            errorMessage: 'Erro ao reenviar e-mail.',
          ),
        );
      }
    });
  }
}
