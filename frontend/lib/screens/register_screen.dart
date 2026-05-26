import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/supabase_user_service.dart';
import '../widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();
  final _userService = SupabaseUserService();
  bool _submitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_submitting) return;

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    setState(() => _submitting = true);
    try {
      final credential = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(username);
        await _userService.upsertProfile(
          id: user.uid,
          username: username,
          bio: '',
          avatarUrl: '',
        );
      }

      await _authService.signOut();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created. Check your email to verify, then sign in.',
          ),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create account',
      subtitle: 'join the matcha community.',
      footer: AuthFooter(
        leading: 'Already a member?',
        action: 'Sign in',
        onTap: widget.onSignIn,
      ),
      children: [
        UsernameField(controller: _usernameController),
        const SizedBox(height: 22),
        EmailField(controller: _emailController),
        const SizedBox(height: 22),
        PasswordField(controller: _passwordController),
        const SizedBox(height: 22),
        PasswordField(
          controller: _confirmPasswordController,
          hintText: 'Confirm Password',
        ),
        const SizedBox(height: 18),
        const TermsRow(),
        const SizedBox(height: 34),
        PrimaryButton(
          label: _submitting ? 'Creating…' : 'Create account',
          onPressed: _submitting ? null : _signUp,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
