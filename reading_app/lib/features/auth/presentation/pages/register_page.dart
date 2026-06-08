import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../library/presentation/controllers/library_controller.dart';
import '../../../library/presentation/pages/create_first_profile_page.dart';

class RegisterScreen extends StatefulWidget {
  final LibraryController libraryController;

  const RegisterScreen({super.key, required this.libraryController});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  static final RegExp _passwordNumberRegex = RegExp(r'\d');

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final pass = _passController.text;

      final credential = await fb.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
      final user = credential.user;

      if (user == null) {
        throw Exception('No se pudo crear la cuenta. Inténtalo nuevamente.');
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'plan': 'free',
        'maxProfiles': 4,
        'maxDevices': 2,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) =>
              CreateMainProfilePage(controller: widget.libraryController),
        ),
        (route) => false,
      );
    } on fb.FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showSnackBar(_firebaseMessage(e));
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        e.toString().replaceFirst('Exception:', '').trim().isEmpty
            ? 'No pudimos crear la cuenta. Inténtalo nuevamente.'
            : e.toString().replaceFirst('Exception:', '').trim(),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Ingresa tu correo electrónico';
    if (!_emailRegex.hasMatch(email)) return 'Ingresa un correo válido';
    return null;
  }

  String? _validatePassword(String? value) {
    final pass = value ?? '';
    if (pass.isEmpty) return 'Ingresa una contraseña';
    if (pass.length < 8) return 'La contraseña debe tener mínimo 8 caracteres';
    if (!_passwordNumberRegex.hasMatch(pass)) {
      return 'La contraseña debe incluir al menos 1 número';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if ((value ?? '').isEmpty) return 'Confirma tu contraseña';
    if (value != _passController.text) return 'Las contraseñas no coinciden';
    return null;
  }

  String _firebaseMessage(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Ese correo ya está registrado';
      case 'invalid-email':
        return 'El correo no es válido';
      case 'weak-password':
        return 'La contraseña no cumple los requisitos';
      case 'network-request-failed':
        return 'Sin conexión. Revisa tu internet e inténtalo de nuevo';
      default:
        return e.message?.trim().isNotEmpty == true
            ? e.message!.trim()
            : 'No pudimos crear la cuenta. Inténtalo nuevamente.';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1A1A1A),
          content: Text(
            message,
            style: GoogleFonts.dmSans(
              color: const Color(0xFFF0EAD8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          const Positioned.fill(child: _RegisterBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  22,
                  24,
                  22,
                  24 + viewInsets.bottom * 0.2,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const _RegisterHeader(),
                      const SizedBox(height: 28),
                      _RegisterCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _RegisterField(
                                controller: _emailController,
                                icon: Icons.mail_outline,
                                placeholder: 'Correo electrónico',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 12),
                              _RegisterField(
                                controller: _passController,
                                icon: Icons.lock_outline,
                                placeholder: 'Contraseña',
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                validator: _validatePassword,
                                suffixIcon: IconButton(
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
                              const SizedBox(height: 12),
                              _RegisterField(
                                controller: _confirmController,
                                icon: Icons.lock_outline,
                                placeholder: 'Confirmar contraseña',
                                obscureText: _obscureConfirm,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                validator: _validateConfirm,
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 54,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFC9A84C),
                                        Color(0xFFA07830),
                                      ],
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      disabledBackgroundColor:
                                          Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.3,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Color(0xFF1A1000),
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            'Crear cuenta',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF1A1000),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta? ',
                            style: GoogleFonts.dmSans(
                              color: const Color(0xFF8A8070),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: Text(
                              'Iniciar sesión',
                              style: GoogleFonts.dmSans(
                                color: const Color(0xFFC9A84C),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
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
        ],
      ),
    );
  }
}

class _RegisterBackground extends StatelessWidget {
  const _RegisterBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Color(0xFF0A0A0A),
        gradient: RadialGradient(
          center: Alignment(0.0, -0.6),
          radius: 0.7,
          colors: [Color(0xFF2D1F00), Color(0xFF0A0A0A)],
        ),
      ),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD4A843), Color(0xFF8A6620)],
            ),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            size: 34,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Mini Read',
          style: GoogleFonts.playfairDisplay(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF0EAD8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Crea tu cuenta para comenzar tu experiencia de lectura.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: const Color(0xFF8A8070),
          ),
        ),
      ],
    );
  }
}

class _RegisterCard extends StatelessWidget {
  final Widget child;

  const _RegisterCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: child,
    );
  }
}

class _RegisterField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String placeholder;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;

  const _RegisterField({
    required this.controller,
    required this.icon,
    required this.placeholder,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: GoogleFonts.dmSans(
        color: const Color(0xFFF0EAD8),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: const Color(0xFFC9A84C),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: GoogleFonts.dmSans(
          color: const Color(0xFF8A8070),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF8A8070)),
        suffixIcon: suffixIcon,
        suffixIconColor: const Color(0xFF8A8070),
        filled: true,
        fillColor: const Color(0xFF171717),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        enabledBorder: _border(),
        focusedBorder: _border(const Color(0xFFC9A84C)),
        errorBorder: _border(const Color(0xFFB85C4B)),
        focusedErrorBorder: _border(const Color(0xFFB85C4B)),
        errorStyle: GoogleFonts.dmSans(
          color: const Color(0xFFE8B7AE),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  OutlineInputBorder _border([Color color = const Color(0xFF2A2A2A)]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 0.8),
    );
  }
}
