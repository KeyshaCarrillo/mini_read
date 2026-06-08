import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_theme.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  final AuthController controller;

  const LoginPage({super.key, required this.controller});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  late final AnimationController _introController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  String? _error;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _buttonPressed = false;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic),
        );
    _introController.forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _cleanError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showPasswordRecoveryNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF201A0C),
        content: Text(
          'La recuperacion de contrasena estara disponible muy pronto.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.92)),
        ),
      ),
    );
  }

  String _cleanError(Object error) {
    final message = error.toString().replaceFirst('Exception:', '').trim();
    return message.isEmpty ? 'No pudimos iniciar sesion.' : message;
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _PremiumLoginBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  22,
                  24,
                  22,
                  24 + viewInsets.bottom * 0.2,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const _LoginHeader(),
                          const SizedBox(height: 30),
                          _GlassLoginCard(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _PremiumTextField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    label: 'Email',
                                    icon: Icons.mail_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      final email = value?.trim() ?? '';
                                      return email.contains('@')
                                          ? null
                                          : 'Escribe un email valido';
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  _PremiumTextField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    label: 'Contrasena',
                                    icon: Icons.lock_rounded,
                                    obscureText: _obscurePassword,
                                    onFieldSubmitted: (_) => _login(),
                                    suffixIcon: IconButton(
                                      tooltip: _obscurePassword
                                          ? 'Mostrar contrasena'
                                          : 'Ocultar contrasena',
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                      ),
                                    ),
                                    validator: (value) {
                                      final password = value ?? '';
                                      return password.length >= 6
                                          ? null
                                          : 'Minimo 6 caracteres';
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _loading
                                          ? null
                                          : _showPasswordRecoveryNotice,
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.gold,
                                        textStyle: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      child: const Text('Recuperar contrasena'),
                                    ),
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 220),
                                    child: _error == null
                                        ? const SizedBox.shrink()
                                        : Padding(
                                            key: ValueKey(_error),
                                            padding: const EdgeInsets.only(
                                              bottom: 14,
                                            ),
                                            child: _ErrorBanner(
                                              message: _error!,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 4),
                                  _PremiumLoginButton(
                                    loading: _loading,
                                    pressed: _buttonPressed,
                                    onTapDown: _loading
                                        ? null
                                        : (_) => setState(
                                            () => _buttonPressed = true,
                                          ),
                                    onTapCancel: _loading
                                        ? null
                                        : () => setState(
                                            () => _buttonPressed = false,
                                          ),
                                    onTapUp: _loading
                                        ? null
                                        : (_) => setState(
                                            () => _buttonPressed = false,
                                          ),
                                    onPressed: _loading ? null : _login,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _CreateAccountLink(
                            loading: _loading,
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                          ),
                        ],
                      ),
                    ),
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

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD9B64C), Color(0xFF7B5B19)],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.gold.withValues(alpha: 0.28),
                blurRadius: 32,
                spreadRadius: -4,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.38),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.24),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 42,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Mini Read',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Playfair Display',
            fontSize: 44,
            fontWeight: FontWeight.w800,
            height: 0.98,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Entra a tu biblioteca, perfiles y lectura con IA.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontFamily: 'Inter',
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _GlassLoginCard extends StatelessWidget {
  final Widget child;

  const _GlassLoginCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          decoration: BoxDecoration(
            color: const Color(0xFF15130F).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.11),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.46),
                blurRadius: 42,
                offset: const Offset(0, 24),
              ),
              BoxShadow(
                color: AppTheme.gold.withValues(alpha: 0.08),
                blurRadius: 34,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PremiumTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const _PremiumTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  State<_PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<_PremiumTextField> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final focused = widget.focusNode.hasFocus;
    final borderColor = focused
        ? AppTheme.gold.withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (focused)
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.12),
              blurRadius: 22,
              spreadRadius: -6,
            ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: widget.obscureText,
        onFieldSubmitted: widget.onFieldSubmitted,
        cursorColor: AppTheme.gold,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Inter',
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: focused
                ? AppTheme.gold.withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.55),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: focused
                ? AppTheme.gold
                : Colors.white.withValues(alpha: 0.48),
          ),
          suffixIcon: widget.suffixIcon,
          suffixIconColor: focused
              ? AppTheme.gold
              : Colors.white.withValues(alpha: 0.5),
          filled: true,
          fillColor: focused
              ? const Color(0xFF211C12).withValues(alpha: 0.86)
              : const Color(0xFF0F0F0E).withValues(alpha: 0.72),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: _fieldBorder(borderColor),
          enabledBorder: _fieldBorder(borderColor),
          focusedBorder: _fieldBorder(AppTheme.gold.withValues(alpha: 0.92)),
          errorBorder: _fieldBorder(AppTheme.coral.withValues(alpha: 0.82)),
          focusedErrorBorder: _fieldBorder(AppTheme.coral),
          errorStyle: const TextStyle(
            color: Color(0xFFFFA092),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        validator: widget.validator,
      ),
    );
  }

  OutlineInputBorder _fieldBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: 1.1),
    );
  }
}

class _PremiumLoginButton extends StatelessWidget {
  final bool loading;
  final bool pressed;
  final GestureTapDownCallback? onTapDown;
  final GestureTapCancelCallback? onTapCancel;
  final GestureTapUpCallback? onTapUp;
  final VoidCallback? onPressed;

  const _PremiumLoginButton({
    required this.loading,
    required this.pressed,
    required this.onTapDown,
    required this.onTapCancel,
    required this.onTapUp,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (_) {},
      child: GestureDetector(
        onTapDown: onTapDown,
        onTapCancel: onTapCancel,
        onTapUp: onTapUp,
        onTap: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        child: AnimatedScale(
          scale: pressed ? 0.985 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: loading ? 0.84 : 1,
            duration: const Duration(milliseconds: 180),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF3D46B),
                    Color(0xFFD4AF37),
                    Color(0xFF9A711E),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.32),
                    blurRadius: 28,
                    spreadRadius: -8,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.34),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: loading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF211602),
                          ),
                        ),
                      )
                    : const Text(
                        'Iniciar sesion',
                        key: ValueKey('label'),
                        style: TextStyle(
                          color: Color(0xFF211602),
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateAccountLink extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _CreateAccountLink({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Aun no tienes cuenta?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: loading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.gold,
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w900,
            ),
          ),
          child: const Text('Crear cuenta'),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.coral.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.coral.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_rounded, color: Color(0xFFFFA092), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFFC0B6),
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumLoginBackground extends StatelessWidget {
  const _PremiumLoginBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF050505), Color(0xFF13110C), Color(0xFF080807)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.7, -0.95),
                  radius: 0.9,
                  colors: [Color(0x553B2D10), Color(0x00000000)],
                ),
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _OrganicLightPainter())),
          Positioned.fill(child: CustomPaint(painter: _GoldParticlePainter())),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.24),
                    Colors.black.withValues(alpha: 0.36),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganicLightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final goldWash = Paint()
      ..color = AppTheme.gold.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 42);
    final mossWash = Paint()
      ..color = AppTheme.moss.withValues(alpha: 0.09)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 46);
    final amberWash = Paint()
      ..color = const Color(0xFFB88B2C).withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    final topRibbon = Path()
      ..moveTo(size.width * 0.62, -40)
      ..cubicTo(
        size.width * 0.9,
        size.height * 0.03,
        size.width * 1.05,
        size.height * 0.16,
        size.width * 0.86,
        size.height * 0.28,
      )
      ..cubicTo(
        size.width * 0.68,
        size.height * 0.39,
        size.width * 0.48,
        size.height * 0.2,
        size.width * 0.62,
        -40,
      );
    canvas.drawPath(topRibbon, goldWash);

    final leftCurve = Path()
      ..moveTo(-90, size.height * 0.52)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.42,
        size.width * 0.3,
        size.height * 0.76,
        size.width * 0.08,
        size.height * 0.92,
      )
      ..cubicTo(
        -70,
        size.height * 1.04,
        -120,
        size.height * 0.68,
        -90,
        size.height * 0.52,
      );
    canvas.drawPath(leftCurve, mossWash);

    final bottomRibbon = Path()
      ..moveTo(size.width * 0.58, size.height + 90)
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.72,
        size.width * 1.12,
        size.height * 0.76,
        size.width + 80,
        size.height * 0.98,
      )
      ..lineTo(size.width + 90, size.height + 110)
      ..close();
    canvas.drawPath(bottomRibbon, amberWash);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GoldParticlePainter extends CustomPainter {
  static const List<Offset> _points = [
    Offset(0.12, 0.18),
    Offset(0.22, 0.74),
    Offset(0.34, 0.1),
    Offset(0.45, 0.86),
    Offset(0.58, 0.22),
    Offset(0.66, 0.66),
    Offset(0.78, 0.14),
    Offset(0.88, 0.46),
    Offset(0.92, 0.82),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var index = 0; index < _points.length; index++) {
      final point = _points[index];
      final radius = index.isEven ? 1.2 : 0.8;
      paint.color = AppTheme.gold.withValues(alpha: index.isEven ? 0.18 : 0.1);
      canvas.drawCircle(
        Offset(point.dx * size.width, point.dy * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
