import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../../library/presentation/controllers/library_controller.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  final AuthController controller;
  final LibraryController libraryController;

  const RegisterPage({
    super.key,
    required this.controller,
    required this.libraryController,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.controller.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/onboarding',
        (route) => false,
      );
    } catch (e) {
      setState(() => _error = _cleanError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _cleanError(Object error) {
    final message = error.toString().replaceFirst('Exception:', '').trim();
    return message.isEmpty ? 'No pudimos crear la cuenta.' : message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.coral,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tu biblioteca empieza aqui',
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.02,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea tu cuenta y despues elegimos edad, gustos y el primer perfil lector.',
                      style: TextStyle(
                        color: AppTheme.ink.withValues(alpha: 0.68),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_rounded),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        return email.contains('@')
                            ? null
                            : 'Escribe un email valido';
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Contrasena',
                        prefixIcon: Icon(Icons.lock_rounded),
                      ),
                      validator: (value) {
                        final password = value ?? '';
                        return password.length >= 6
                            ? null
                            : 'Minimo 6 caracteres';
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      onFieldSubmitted: (_) => _register(),
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contrasena',
                        prefixIcon: Icon(Icons.verified_user_rounded),
                      ),
                      validator: (value) {
                        return value == _passwordController.text
                            ? null
                            : 'Las contrasenas no coinciden';
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: AppTheme.coral,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _register,
                        child: Text(_loading ? 'Creando...' : 'Crear cuenta'),
                      ),
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
