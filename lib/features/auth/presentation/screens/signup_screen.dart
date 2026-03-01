import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/core/theme/app_theme.dart'; // Certifique-se que o AppTheme está acessível
import 'package:physigest/features/auth/presentation/bloc/signup/signup_bloc.dart';
import 'package:physigest/features/auth/presentation/bloc/signup/signup_event.dart';
import 'package:physigest/features/auth/presentation/bloc/signup/signup_state.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SignUpBloc>(),
      child: const SignUpView(),
    );
  }
}

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = AppTheme.primaryColor;

    return Scaffold(
      // Fundo consistente com a LoginView
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF8FAFC),
              primary.withOpacity(0.05),
              const Color(0xFFF1F5F9),
            ],
          ),
        ),
        child: BlocListener<SignUpBloc, SignUpState>(
          listener: (context, state) {
            if (state.status == SignUpStatus.success) {
              context.go('/');
            } else if (state.status == SignUpStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // CABEÇALHO
                      const Icon(
                        Icons.person_add_rounded,
                        size: 48,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Criar Conta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Text(
                        'Junte-se ao PhysiGest e otimize sua clínica.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 14),
                      ),
                      const SizedBox(height: 32),

                      // NOME COMPLETO
                      _buildLabel('Nome Completo'),
                      BlocBuilder<SignUpBloc, SignUpState>(
                        buildWhen: (p, c) => p.name != c.name,
                        builder: (context, state) {
                          return TextField(
                            onChanged: (v) => context.read<SignUpBloc>().add(SignUpNameChanged(v)),
                            decoration: _inputDecoration('Como quer ser chamado?', Icons.person_outline_rounded),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // E-MAIL
                      _buildLabel('E-mail Profissional'),
                      BlocBuilder<SignUpBloc, SignUpState>(
                        buildWhen: (p, c) => p.email != c.email,
                        builder: (context, state) {
                          return TextField(
                            onChanged: (v) => context.read<SignUpBloc>().add(SignUpEmailChanged(v)),
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration('seu@email.com', Icons.mail_outline_rounded),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // SENHA
                      _buildLabel('Senha'),
                      BlocBuilder<SignUpBloc, SignUpState>(
                        buildWhen: (p, c) => p.password != c.password || p.status != c.status,
                        builder: (context, state) {
                          return TextField(
                            onChanged: (v) => context.read<SignUpBloc>().add(SignUpPasswordChanged(v)),
                            obscureText: true,
                            decoration: _inputDecoration('Mínimo 8 caracteres', Icons.lock_outline_rounded).copyWith(
                              errorText: state.password.isNotEmpty && !state.isPasswordValid
                                  ? 'A senha deve ter no mínimo 8 caracteres'
                                  : null,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // CONFIRMAR SENHA
                      _buildLabel('Confirmar Senha'),
                      BlocBuilder<SignUpBloc, SignUpState>(
                        builder: (context, state) {
                          return TextField(
                            onChanged: (v) => context.read<SignUpBloc>().add(SignUpConfirmPasswordChanged(v)),
                            obscureText: true,
                            decoration: _inputDecoration('Repita a senha', Icons.lock_clock_outlined).copyWith(
                              errorText: state.confirmPassword.isNotEmpty && !state.doPasswordsMatch
                                  ? 'As senhas não coincidem'
                                  : null,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // BOTÃO CRIAR CONTA
                      BlocBuilder<SignUpBloc, SignUpState>(
                        builder: (context, state) {
                          return state.status == SignUpStatus.loading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: state.isValid
                                      ? () => context.read<SignUpBloc>().add(const SignUpSubmitted())
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: const Text('Finalizar Cadastro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                );
                        },
                      ),
                      const SizedBox(height: 24),

                      // RODAPÉ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Já possui uma conta?', style: TextStyle(color: Colors.black54)),
                          TextButton(
                            onPressed: () => context.push('/login'),
                            child: Text('Entrar agora', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helpers de UI para manter a consistência com a LoginView
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: Colors.black38),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
      errorStyle: const TextStyle(fontSize: 11),
    );
  }
}