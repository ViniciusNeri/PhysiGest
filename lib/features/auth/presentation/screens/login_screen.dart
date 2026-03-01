import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:physigest/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:physigest/features/auth/presentation/bloc/login/login_event.dart';
import 'package:physigest/features/auth/presentation/bloc/login/login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = AppTheme.primaryColor;

    return Scaffold(
      // Fundo com um degradê sutil para profundidade
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
        child: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.success) {
              context.go('/');
            } else if (state.status == LoginStatus.failure) {
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
                constraints: const BoxConstraints(maxWidth: 450),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
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
                      // LOGO E TÍTULO
                      const Icon(
                        Icons.monitor_heart_rounded,
                        size: 64,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'PhysiGest',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Text(
                        'Gestão inteligente para fisioterapia',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 14),
                      ),
                      const SizedBox(height: 40),

                      // CAMPO E-MAIL
                      _buildLabel('E-mail'),
                      BlocBuilder<LoginBloc, LoginState>(
                        buildWhen: (p, c) => p.email != c.email,
                        builder: (context, state) {
                          return TextField(
                            onChanged: (v) => context.read<LoginBloc>().add(EmailChanged(v)),
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration('exemplo@email.com', Icons.mail_outline_rounded),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // CAMPO SENHA
                      _buildLabel('Senha'),
                      BlocBuilder<LoginBloc, LoginState>(
                        buildWhen: (p, c) => p.password != c.password,
                        builder: (context, state) {
                          return TextField(
                            onChanged: (v) => context.read<LoginBloc>().add(PasswordChanged(v)),
                            obscureText: true,
                            decoration: _inputDecoration('••••••••', Icons.lock_outline_rounded),
                          );
                        },
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          style: TextButton.styleFrom(foregroundColor: primary),
                          child: const Text('Esqueceu a senha?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // BOTÃO ENTRAR
                      BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          return state.status == LoginStatus.loading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: state.isValid
                                      ? () => context.read<LoginBloc>().add(const LoginButtonPressed())
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: const Text('Entrar na conta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                );
                        },
                      ),
                      const SizedBox(height: 32),

                      // DIVISOR
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.withOpacity(0.2))),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OU', style: TextStyle(color: Colors.black26, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(child: Divider(color: Colors.grey.withOpacity(0.2))),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // GOOGLE LOGIN
                      OutlinedButton.icon(
                        onPressed: () => context.read<LoginBloc>().add(const GoogleLoginPressed()),
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text('Entrar com Google', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // RODAPÉ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Ainda não tem conta?', style: TextStyle(color: Colors.black54)),
                          TextButton(
                            onPressed: () => context.push('/signup'),
                            child: Text('Comece agora', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
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

  // Helpers para manter o código limpo
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF334155)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: Colors.black38),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
    );
  }
}