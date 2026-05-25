import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';

import 'login_screen.dart';
import 'register_screen.dart';

enum AuthMode { signIn, signUp }

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  AuthMode _mode = AuthMode.signIn;
  final _authService = AuthService();

  void _setMode(AuthMode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (user != null) {
          if (!user.emailVerified) {
            Future.microtask(() => _authService.signOut());
          }
          return user.emailVerified
              ? const HomeScreen()
              : LoginScreen(
                  key: const ValueKey('sign-in'),
                  onCreateAccount: () => _setMode(AuthMode.signUp),
                );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _mode == AuthMode.signIn
              ? LoginScreen(
                  key: const ValueKey('sign-in'),
                  onCreateAccount: () => _setMode(AuthMode.signUp),
                )
              : RegisterScreen(
                  key: const ValueKey('sign-up'),
                  onSignIn: () => _setMode(AuthMode.signIn),
                ),
        );
      },
    );
  }
}
