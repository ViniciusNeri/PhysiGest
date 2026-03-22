import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/login_usecase.dart';

import 'signup_event.dart';
import 'signup_state.dart';

@injectable
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final SignUpUseCase _signUpUseCase;

  SignUpBloc(this._signUpUseCase) : super(const SignUpState()) {
    on<SignUpNameChanged>(_onNameChanged);
    on<SignUpEmailChanged>(_onEmailChanged);
    on<SignUpPasswordChanged>(_onPasswordChanged);
    on<SignUpConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SignUpSubmitted>(_onSubmitted);
  }

  void _onNameChanged(SignUpNameChanged event, Emitter<SignUpState> emit) {
    emit(state.copyWith(name: event.name, status: SignUpStatus.initial));
  }

  void _onEmailChanged(SignUpEmailChanged event, Emitter<SignUpState> emit) {
    emit(state.copyWith(email: event.email, status: SignUpStatus.initial));
  }

  void _onPasswordChanged(SignUpPasswordChanged event, Emitter<SignUpState> emit) {
    emit(state.copyWith(password: event.password, status: SignUpStatus.initial));
  }

  void _onConfirmPasswordChanged(SignUpConfirmPasswordChanged event, Emitter<SignUpState> emit) {
    emit(state.copyWith(confirmPassword: event.confirmPassword, status: SignUpStatus.initial));
  }

  Future<void> _onSubmitted(SignUpSubmitted event, Emitter<SignUpState> emit) async {
    if (!state.isValid) return;

    emit(state.copyWith(status: SignUpStatus.loading));
    try {
      // Chama o caso de uso que conecta na API
      final user = await _signUpUseCase(state.name, state.email, state.password);
      
      emit(state.copyWith(status: SignUpStatus.success));
    } catch (e) {
      // Remove o prefixo "Exception:" da mensagem para o usuário
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(state.copyWith(status: SignUpStatus.failure, errorMessage: msg));
    }
  }
}
