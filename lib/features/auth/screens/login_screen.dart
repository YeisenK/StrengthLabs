import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: [
            // Grid background
            const _GridBackground(),
            // Content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),

                      // ── Logo ──
                      const _LogoBadge(),
                      const SizedBox(height: 24),

                      // ── Title ──
                      const Text(
                        'STRENGTH\nLABS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'BarlowCondensed',
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          height: 0.95,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'ADAPTIVE INTELLIGENCE',
                        style: TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 11,
                          letterSpacing: 4,
                          color: AppColors.accent2,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ── Email field ──
                      _SLTextField(
                        label: 'EMAIL',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // ── Password field ──
                      _SLTextField(
                        label: 'CONTRASEÑA',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        suffix: GestureDetector(
                          onTap: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),

                      // ── Forgot password ──
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 0),
                          ),
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              fontFamily: 'ShareTechMono',
                              fontSize: 10,
                              letterSpacing: 0.5,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ── Login button ──
                      _SLPrimaryButton(
                        label: 'INICIAR SESIÓN',
                        isLoading: _isLoading,
                        onTap: () async {
                          setState(() => _isLoading = true);
                          await Future.delayed(const Duration(seconds: 2));
                          setState(() => _isLoading = false);
                        },
                      ),
                      const SizedBox(height: 28),

                      // ── Divider ──
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.border2,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'O CONTINUAR CON',
                              style: TextStyle(
                                fontFamily: 'ShareTechMono',
                                fontSize: 9,
                                letterSpacing: 2,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.border2,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Google button ──
                      _SLGoogleButton(onTap: () {}),
                      const SizedBox(height: 32),

                      // ── Register link ──
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'ShareTechMono',
                            fontSize: 11,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                          children: [
                            const TextSpan(text: '¿No tienes cuenta? '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  'Regístrate gratis',
                                  style: TextStyle(
                                    fontFamily: 'ShareTechMono',
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// GRID BACKGROUND
// ─────────────────────────────────────────────────────────
class _GridBackground extends StatelessWidget {
  const _GridBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A2E22).withOpacity(0.55)
      ..strokeWidth = 0.5;

    const step = 28.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────
// LOGO BADGE
// ─────────────────────────────────────────────────────────
class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.18),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.bolt_rounded,
        color: AppColors.accent,
        size: 38,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// TEXT FIELD
// ─────────────────────────────────────────────────────────
class _SLTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _SLTextField({
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'ShareTechMono',
            fontSize: 9,
            letterSpacing: 2.5,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.accent.withOpacity(0.45), width: 1.2),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: 'ShareTechMono',
              fontSize: 13,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              suffixIcon: suffix != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: suffix,
                    )
                  : null,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            cursorColor: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// PRIMARY BUTTON
// ─────────────────────────────────────────────────────────
class _SLPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const _SLPrimaryButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.bg),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontFamily: 'BarlowCondensed',
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: 3,
                  color: AppColors.bg,
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// GOOGLE BUTTON
// ─────────────────────────────────────────────────────────
class _SLGoogleButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SLGoogleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border2, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" icon using colored squares
            _GoogleIcon(),
            const SizedBox(width: 12),
            const Text(
              'Google',
              style: TextStyle(
                fontFamily: 'BarlowCondensed',
                fontWeight: FontWeight.w600,
                fontSize: 17,
                letterSpacing: 1,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Draw the G using arcs and rects
    final paintBlue = Paint()..color = const Color(0xFF4285F4);
    final paintRed = Paint()..color = const Color(0xFFEA4335);
    final paintYellow = Paint()..color = const Color(0xFFFBBC05);
    final paintGreen = Paint()..color = const Color(0xFF34A853);

    // Top-right arc (blue)
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -1.57, // -90 deg
      1.57,  // 90 deg
      false,
      paintBlue..style = PaintingStyle.stroke..strokeWidth = size.width * 0.22,
    );
    // Bottom-right arc (green)
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      0,
      1.57,
      false,
      paintGreen..style = PaintingStyle.stroke..strokeWidth = size.width * 0.22,
    );
    // Bottom-left arc (yellow)
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      1.57,
      1.57,
      false,
      paintYellow..style = PaintingStyle.stroke..strokeWidth = size.width * 0.22,
    );
    // Top-left arc (red)
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      3.14,
      1.57,
      false,
      paintRed..style = PaintingStyle.stroke..strokeWidth = size.width * 0.22,
    );

    // Right bar for "G" cutout (the horizontal dash)
    canvas.drawRect(
      Rect.fromLTWH(c.dx, c.dy - size.height * 0.13, r, size.height * 0.26),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}