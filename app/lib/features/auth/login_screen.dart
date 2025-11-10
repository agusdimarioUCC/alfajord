import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/routes.dart';
import '../../shared/widgets/input_field.dart';
import '../../shared/widgets/primary_button.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);
    final success = await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text.trim());
    setState(() => _submitting = false);

    if (success) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } else {
      final error = ref.read(authProvider).error ?? 'No se pudo iniciar sesión';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value != null && value.contains('@') ? null : 'Email inválido',
              ),
              const SizedBox(height: 12),
              InputField(
                label: 'Contraseña',
                controller: _passwordController,
                obscureText: true,
                validator: (value) => value != null && value.length >= 6
                    ? null
                    : 'Mínimo 6 caracteres',
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Iniciar sesión',
                isLoading: _submitting,
                onPressed: _handleSubmit,
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                child: const Text('Crear cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
