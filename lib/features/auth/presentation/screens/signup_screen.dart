import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:physigest/core/di/injection.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
      ),
      body: SafeArea(
        child: BlocListener<SignUpBloc, SignUpState>(
          listener: (context, state) {
            if (state.status == SignUpStatus.success) {
              context.go('/');
            } else if (state.status == SignUpStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage)),
              );
            }
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocBuilder<SignUpBloc, SignUpState>(
                    buildWhen: (previous, current) => previous.name != current.name,
                    builder: (context, state) {
                      return TextField(
                        onChanged: (name) =>
                            context.read<SignUpBloc>().add(SignUpNameChanged(name)),
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<SignUpBloc, SignUpState>(
                    buildWhen: (previous, current) => previous.email != current.email,
                    builder: (context, state) {
                      return TextField(
                        onChanged: (email) =>
                            context.read<SignUpBloc>().add(SignUpEmailChanged(email)),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<SignUpBloc, SignUpState>(
                    buildWhen: (previous, current) => previous.password != current.password,
                    builder: (context, state) {
                      return TextField(
                        onChanged: (password) =>
                            context.read<SignUpBloc>().add(SignUpPasswordChanged(password)),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          errorText: state.password.isNotEmpty && !state.isPasswordValid
                              ? 'A senha deve ter no mínimo 8 caracteres'
                              : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<SignUpBloc, SignUpState>(
                    builder: (context, state) {
                      return TextField(
                        onChanged: (confirmPassword) =>
                            context.read<SignUpBloc>().add(SignUpConfirmPasswordChanged(confirmPassword)),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Senha',
                          prefixIcon: const Icon(Icons.lock_clock_outlined),
                          errorText: state.confirmPassword.isNotEmpty && !state.doPasswordsMatch
                              ? 'As senhas não coincidem'
                              : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<SignUpBloc, SignUpState>(
                    builder: (context, state) {
                      return state.status == SignUpStatus.loading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: state.isValid
                                  ? () {
                                      context.read<SignUpBloc>().add(const SignUpSubmitted());
                                    }
                                  : null,
                              child: const Text('Criar Conta'),
                            );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Já tem conta?'),
                      TextButton(
                        onPressed: () => context.push('/login'),
                        child: const Text('Entre aqui'),
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
    );
  }
}
