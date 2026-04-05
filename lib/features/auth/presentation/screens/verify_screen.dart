import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:physigest/features/auth/presentation/bloc/verify/verify_bloc.dart';
import 'package:physigest/features/auth/presentation/bloc/verify/verify_event.dart'; // Import necessário
import 'package:physigest/features/auth/presentation/bloc/verify/verify_state.dart'; // Import necessário

class VerificationScreen extends StatelessWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VerifyBloc>()..add(VerifyEmailChanged(email)),
      child: VerificationView(email: email),
    );
  }
}

class VerificationView extends StatelessWidget {
  final String email;
  const VerificationView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final Color primary = AppTheme.primaryColor;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF8FAFC),
              primary.withValues(alpha: 0.05),
              const Color(0xFFF1F5F9),
            ],
          ),
        ),
        child: BlocListener<VerifyBloc, VerifyState>(
          listener: (context, state) {
            if (state.status == VerifyStatus.success) {
              context.go('/'); // Navega para a Home ou Login após sucesso
            } else if (state.status == VerifyStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.mark_email_read_rounded,
                        size: 48,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Verifique seu E-mail',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enviamos um código de 6 dígitos para\n$email',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildLabel('Código de Verificação'),
                      TextField(
                        onChanged: (v) => context.read<VerifyBloc>().add(
                          VerifyCodeChanged(v),
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                        maxLength: 6,
                        decoration: _inputDecoration(
                          '000000',
                          Icons.numbers_rounded,
                        ).copyWith(counterText: ""),
                      ),
                      const SizedBox(height: 32),

                      BlocBuilder<VerifyBloc, VerifyState>(
                        builder: (context, state) {
                          return state.status == VerifyStatus.loading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: state.isCodeValid
                                      ? () => context.read<VerifyBloc>().add(
                                          VerifySubmitted(email),
                                        )
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Confirmar Código',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                        },
                      ),
                      const SizedBox(height: 24),

                      Column(
                        children: [
                          const Text(
                            'Não recebeu o código?',
                            style: TextStyle(color: Colors.black54),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<VerifyBloc>().add(
                                VerifyResendCodeRequested(email),
                              );
                            },
                            child: Text(
                              'Reenviar novo código',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: const Text(
                              'Alterar e-mail',
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: 13,
                              ),
                            ),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: Color(0xFF334155),
        ),
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
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
      hintStyle: const TextStyle(
        color: Colors.black26,
        fontSize: 13,
        letterSpacing: 0,
      ),
    );
  }
}
