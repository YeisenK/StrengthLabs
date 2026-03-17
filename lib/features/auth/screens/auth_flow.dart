import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthFlow extends ConsumerStatefulWidget {
  const AuthFlow({super.key});

  @override
  ConsumerState<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends ConsumerState<AuthFlow> {
  bool _showRegister = false;

  void _goToRegister() {
    // Clear any previous errors when switching screens
    ref.read(authProvider.notifier).setError(null);
    setState(() => _showRegister = true);
  }

  void _goToLogin() {
    ref.read(authProvider.notifier).setError(null);
    setState(() => _showRegister = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_showRegister) {
      return RegisterScreen(onLoginTap: _goToLogin);
    }
    return LoginScreen(onRegisterTap: _goToRegister);
  }
}
