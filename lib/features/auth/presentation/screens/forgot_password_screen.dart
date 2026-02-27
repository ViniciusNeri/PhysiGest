import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:physigest/features/auth/presentation/bloc/forgot_password/forgot_password_event.dart';
import 'package:physigest/features/auth/presentation/bloc/forgot_password/forgot_password_state.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ForgotPasswordBloc>(),
      child: const ForgotPasswordView(),
    );
  }
}

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
      ),
      body: SafeArea(
        child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
          listener: (context, state) {
            if (state.status == ForgotPasswordStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link de recuperação enviado para o e-mail!')),
              );
              context.pop();
            } else if (state.status == ForgotPasswordStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage)),
              );
            }
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Informe de e-mail associado à sua conta para receber um link de recuperação.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                  buildWhen: (previous, current) => previous.email != current.email,
                  builder: (context, state) {
                    return TextField(
                      onChanged: (email) =>
                          context.read<ForgotPasswordBloc>().add(ForgotPasswordEmailChanged(email)),
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                  builder: (context, state) {
                    return state.status == ForgotPasswordStatus.loading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: state.isValid
                                ? () {
                                    context.read<ForgotPasswordBloc>().add(const ForgotPasswordSubmitted());
                                  }
                                : null,
                            child: const Text('Enviar Link'),
                          );
                  },
                ),
              ],
            ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}
