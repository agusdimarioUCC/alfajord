import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/routes.dart';
import '../../shared/widgets/input_field.dart';
import '../../shared/widgets/primary_button.dart';
import 'auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);
    final success = await ref.read(authProvider.notifier).register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
    setState(() => _submitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso, iniciá sesión.')),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else if (mounted) {
      final error = ref.read(authProvider).error ?? 'No se pudo registrar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              InputField(
                label: 'Nombre visible',
                controller: _nameController,
                validator: (value) =>
                    value != null && value.isNotEmpty ? null : 'Campo obligatorio',
              ),
              const SizedBox(height: 12),
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
                label: 'Registrarse',
                isLoading: _submitting,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
