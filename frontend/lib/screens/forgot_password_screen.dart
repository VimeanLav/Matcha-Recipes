import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();
  late final TextEditingController _emailController;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email.')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      await _authService.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent. Check your inbox.')),
      );
      Navigator.of(context).pop();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Forgot password?',
      subtitle: "No worries. Enter your email and we'll send you a link to reset it.",
      footer: AuthFooter(
        leading: 'Remembered it?',
        action: 'Back to sign in',
        onTap: () => Navigator.of(context).pop(),
      ),
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const SizedBox(height: 8),
        EmailField(controller: _emailController),
        const SizedBox(height: 28),
        PrimaryButton(
          label: _sending ? 'Sending…' : 'Send reset link',
          onPressed: _sending ? null : _sendReset,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
