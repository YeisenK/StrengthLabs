import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final VoidCallback onLoginTap;

  const RegisterScreen({super.key, required this.onLoginTap});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password != confirm) {
      ref.read(authProvider.notifier).setError('Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);
    await ref.read(authProvider.notifier).register(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: password,
        );
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final errorMsg = authState is AuthUnauthenticated ? authState.error : null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: [
            const _GridBackground(),
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
                        'CREAR\nCUENTA',
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
                      const SizedBox(height: 36),

                      // ── Nombre y Apellido ──
                      Row(
                        children: [
                          Expanded(
                            child: _SLTextField(
                              label: 'NOMBRE',
                              controller: _firstNameController,
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SLTextField(
                              label: 'APELLIDO',
                              controller: _lastNameController,
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Email ──
                      _SLTextField(
                        label: 'EMAIL',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // ── Contraseña ──
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
                      const SizedBox(height: 16),

                      // ── Confirmar contraseña ──
                      _SLTextField(
                        label: 'CONFIRMAR CONTRASEÑA',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        suffix: GestureDetector(
                          onTap: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                          child: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),

                      // ── Error message ──
                      if (errorMsg != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.riskRed.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.riskRed.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            errorMsg,
                            style: const TextStyle(
                              fontFamily: 'ShareTechMono',
                              fontSize: 10,
                              letterSpacing: 0.5,
                              color: AppColors.riskRed,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Register button ──
                      _SLPrimaryButton(
                        label: 'CREAR CUENTA',
                        isLoading: _isLoading,
                        onTap: _handleRegister,
                      ),
                      const SizedBox(height: 32),

                      // ── Login link ──
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'ShareTechMono',
                            fontSize: 11,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                          children: [
                            const TextSpan(text: '¿Ya tienes cuenta? '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: widget.onLoginTap,
                                child: const Text(
                                  'Iniciar sesión',
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
      ..color = const Color(0xFF14172B).withOpacity(0.60)
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
  final TextCapitalization textCapitalization;
  final Widget? suffix;

  const _SLTextField({
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
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
            textCapitalization: textCapitalization,
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
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.bg),
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
