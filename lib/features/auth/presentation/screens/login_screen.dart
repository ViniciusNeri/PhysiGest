import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:physigest/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:physigest/features/auth/presentation/bloc/login/login_event.dart';
import 'package:physigest/features/auth/presentation/bloc/login/login_state.dart';
import 'package:physigest/core/storage/local_storage.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_bloc.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_event.dart';
import 'package:physigest/core/utils/app_alerts.dart';

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
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

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
        child: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) async {
            if (state.status == LoginStatus.authenticated &&
                state.token != null) {
              await getIt<LocalStorage>().saveToken(state.token!);
              if (context.mounted) {
                context.read<SettingsBloc>().add(LoadSettings());
                context.go('/');
              }
            } else if (state.status == LoginStatus.failure) {
              AppAlerts.error(context, state.errorMessage);
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 24 : 40,
                        vertical: isMobile ? 32 : 50,
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
                            'Gestão inteligente para sua clínica',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black45, fontSize: 14),
                          ),
                          const SizedBox(height: 40),

                          _buildLabel('E-mail'),
                          BlocBuilder<LoginBloc, LoginState>(
                            buildWhen: (p, c) => p.email != c.email,
                            builder: (context, state) {
                              return TextField(
                                onChanged: (v) =>
                                    context.read<LoginBloc>().add(EmailChanged(v)),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: _inputDecoration(
                                  'exemplo@email.com',
                                  Icons.mail_outline_rounded,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildLabel('Senha'),
                          BlocBuilder<LoginBloc, LoginState>(
                            buildWhen: (p, c) => p.password != c.password,
                            builder: (context, state) {
                              return TextField(
                                onChanged: (v) => context.read<LoginBloc>().add(
                                  PasswordChanged(v),
                                ),
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (v) {
                                  if (state.isValid) {
                                    context.read<LoginBloc>().add(
                                          const LoginButtonPressed(),
                                        );
                                  }
                                },
                                decoration: _inputDecoration(
                                  '••••••••',
                                  Icons.lock_outline_rounded,
                                ),
                              );
                            },
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              style: TextButton.styleFrom(foregroundColor: primary),
                              child: const Text(
                                'Esqueceu a senha?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          BlocBuilder<LoginBloc, LoginState>(
                            builder: (context, state) {
                              if (state.status == LoginStatus.loading ||
                                  state.status == LoginStatus.authenticated) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return ElevatedButton(
                                onPressed: state.isValid
                                    ? () => context.read<LoginBloc>().add(
                                        const LoginButtonPressed(),
                                      )
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Entrar na conta',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),

                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Colors.grey.withValues(alpha: 0.2)),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OU',
                                  style: TextStyle(
                                    color: Colors.black26,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Colors.grey.withValues(alpha: 0.2)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          OutlinedButton.icon(
                            onPressed: () => context.read<LoginBloc>().add(
                              const GoogleLoginPressed(),
                            ),
                            icon: const Icon(Icons.g_mobiledata, size: 28),
                            label: const Text(
                              'Entrar com Google',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Ainda não tem conta?',
                                style: TextStyle(color: Colors.black54),
                              ),
                              TextButton(
                                onPressed: () => context.push('/signup'),
                                child: Text(
                                  'Comece agora',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Versão 1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '© 2026 PhysiGest. Todos os direitos reservados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black26,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
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
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
    );
  }
}
