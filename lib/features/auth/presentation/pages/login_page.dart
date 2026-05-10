import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  final AuthController controller;

  const LoginPage({super.key, required this.controller});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.controller.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/profiles', (route) => false);
    } catch (e) {
      setState(() => _error = _cleanError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _cleanError(Object error) {
    final message = error.toString().replaceFirst('Exception:', '').trim();
    return message.isEmpty ? 'No pudimos iniciar sesion.' : message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.moss,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Mini Read',
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entra a tu biblioteca, perfiles y lectura con IA.',
                    style: TextStyle(
                      color: AppTheme.ink.withValues(alpha: 0.68),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
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
                          obscureText: _obscurePassword,
                          onFieldSubmitted: (_) => _login(),
                          decoration: InputDecoration(
                            labelText: 'Contrasena',
                            prefixIcon: const Icon(Icons.lock_rounded),
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Mostrar contrasena'
                                  : 'Ocultar contrasena',
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                              ),
                            ),
                          ),
                          validator: (value) {
                            final password = value ?? '';
                            return password.length >= 6
                                ? null
                                : 'Minimo 6 caracteres';
                          },
                        ),
                      ],
                    ),
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
                      onPressed: _loading ? null : _login,
                      child: Text(_loading ? 'Entrando...' : 'Iniciar sesion'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Crear cuenta'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
