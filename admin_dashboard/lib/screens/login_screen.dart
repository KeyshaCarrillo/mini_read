import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../core/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _emailFocused = false;
  bool _passwordFocused = false;
  bool _isButtonHovered = false;
  bool _isCardHovered = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (mounted) setState(() => _emailFocused = _emailFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      if (mounted) {
        setState(() => _passwordFocused = _passwordFocusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isChecking = auth.status == AuthStatus.checking;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      Theme.of(context).textTheme,
    );

    return Scaffold(
      body: Stack(
        children: [
          const _LoginBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 740;
                    return MouseRegion(
                      onEnter: (_) => setState(() => _isCardHovered = true),
                      onExit: (_) => setState(() => _isCardHovered = false),
                      child:
                          AnimatedContainer(
                                duration: 280.ms,
                                curve: Curves.easeOut,
                                transform: Matrix4.identity()
                                  ..translate(0.0, _isCardHovered ? -2.0 : 0.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x2A0C1D6A),
                                      blurRadius: 52,
                                      offset: Offset(0, 24),
                                    ),
                                    BoxShadow(
                                      color: Color(0x1F000000),
                                      blurRadius: 14,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 4,
                                      sigmaY: 4,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.65,
                                          ),
                                        ),
                                      ),
                                      child: SizedBox(
                                        height: isCompact ? null : 720,
                                        child: isCompact
                                            ? _buildCompactLayout(
                                                context,
                                                auth,
                                                isChecking,
                                                colorScheme,
                                                textTheme,
                                              )
                                            : Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: _buildBrandPanel(
                                                      textTheme,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 6,
                                                    child: _buildFormPanel(
                                                      context,
                                                      auth,
                                                      isChecking,
                                                      colorScheme,
                                                      textTheme,
                                                      largePadding: true,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 420.ms)
                              .slideY(
                                begin: 0.02,
                                duration: 420.ms,
                                curve: Curves.easeOutCubic,
                              ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLayout(
    BuildContext context,
    AuthController auth,
    bool isChecking,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 260,
          width: double.infinity,
          child: _buildBrandPanel(textTheme),
        ),
        _buildFormPanel(
          context,
          auth,
          isChecking,
          colorScheme,
          textTheme,
          largePadding: false,
        ),
      ],
    );
  }

  Widget _buildBrandPanel(TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFF020A69),
            Color(0xFF122A9E),
            Color(0xFF3355CF),
          ],
        ),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        ),
      ),
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned(
              top: -84,
              left: -74,
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 110,
              left: -78,
              child: Transform.rotate(
                angle: 0.62,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(58),
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -92,
              right: -64,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.02),
                      Colors.black.withValues(alpha: 0.08),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 30,
              right: 36,
              child: Opacity(
                opacity: 0.42,
                child: Column(
                  children: List.generate(
                    5,
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: List.generate(
                          4,
                          (c) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(36, 40, 36, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'ADMIN PORTAL',
                            maxLines: 1,
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Spacer(),
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: Colors.white.withValues(alpha: 0.12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.2),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      size: 58,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Administrador',
                    style: textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 62,
                    height: 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF57A0FF), Color(0xFF7388FF)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Centro administrativo exclusivo\npara usuarios con rol admin.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shield_moon_rounded,
                            color: Colors.white,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                                height: 1.32,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Seguridad · Control · Rendimiento\n',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text:
                                      'Plataforma robusta y segura para gestionar tu sistema.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormPanel(
    BuildContext context,
    AuthController auth,
    bool isChecking,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required bool largePadding,
  }) {
    final inputTheme = Theme.of(context).inputDecorationTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        largePadding ? 64 : 24,
        largePadding ? 34 : 28,
        largePadding ? 64 : 24,
        largePadding ? 34 : 30,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: inputTheme.copyWith(
            filled: true,
            fillColor: const Color(0xF8F8FAFF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 21,
            ),
            hintStyle: textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF727A99),
              fontWeight: FontWeight.w500,
            ),
            prefixIconColor: const Color(0xFF626A8D),
            suffixIconColor: const Color(0xFF626A8D),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD6DDF4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF2E49C8),
                width: 1.6,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.error, width: 1.4),
            ),
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: largePadding ? 700 : 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F5FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFDCE2FB)),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: Color(0xFF2E49C8),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Acceso seguro',
                            style: textTheme.displaySmall?.copyWith(
                              color: const Color(0xFF081460),
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ingresa con tus credenciales para administrar la plataforma.',
                      style: textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF50597C),
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 44),
                    _buildInputShell(
                      isFocused: _emailFocused,
                      child: TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Correo administrador',
                          prefixIcon: _inputPrefixIcon(
                            Icons.alternate_email_rounded,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return 'Ingresa un correo valido.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildInputShell(
                      isFocused: _passwordFocused,
                      child: TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => isChecking ? null : _submit(),
                        decoration: InputDecoration(
                          hintText: 'Contrasena',
                          prefixIcon: _inputPrefixIcon(
                            Icons.lock_outline_rounded,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                            tooltip: _obscurePassword
                                ? 'Mostrar contrasena'
                                : 'Ocultar contrasena',
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Minimo 6 caracteres.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (auth.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.error.withValues(alpha: 0.24),
                          ),
                        ),
                        child: Text(
                          auth.errorMessage!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    MouseRegion(
                      onEnter: (_) => setState(() => _isButtonHovered = true),
                      onExit: (_) => setState(() => _isButtonHovered = false),
                      child: AnimatedContainer(
                        duration: 220.ms,
                        curve: Curves.easeOut,
                        transform: Matrix4.identity()
                          ..translate(0.0, _isButtonHovered ? -1.5 : 0.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF03107A), Color(0xFF1A35B5)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1D36AA).withValues(
                                alpha: _isButtonHovered ? 0.45 : 0.32,
                              ),
                              blurRadius: _isButtonHovered ? 26 : 18,
                              offset: Offset(0, _isButtonHovered ? 12 : 8),
                            ),
                          ],
                        ),
                        child: FilledButton.icon(
                          onPressed: isChecking ? null : _submit,
                          icon: const SizedBox.shrink(),
                          label: Row(
                            children: [
                              if (isChecking)
                                const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.admin_panel_settings_rounded,
                                  size: 20,
                                ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Entrar al dashboard',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const Icon(Icons.arrow_forward_rounded, size: 24),
                            ],
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size.fromHeight(64),
                            textStyle: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD9E1FF)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: Color(0xFF3042A8),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF3D4568),
                                  height: 1.35,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Nota: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        'si tu usuario aparece como "user" en Firestore, cambia ese campo a "admin" para acceder.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildInputShell({required bool isFocused, required Widget child}) {
    return AnimatedContainer(
      duration: 180.ms,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? const Color(0xFF3555D8).withValues(alpha: 0.18)
                : Colors.transparent,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _inputPrefixIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF0F2FA),
          border: Border.all(color: const Color(0xFFE2E7F8)),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthController>().signIn(
      _emailController.text,
      _passwordController.text,
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F7FF), Color(0xFFEDEFFD), Color(0xFFE9EDFD)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2343CA).withValues(alpha: 0.09),
              ),
            ),
          ),
          Positioned(
            right: -70,
            bottom: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(72),
                color: const Color(0xFF0E2DAA).withValues(alpha: 0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
