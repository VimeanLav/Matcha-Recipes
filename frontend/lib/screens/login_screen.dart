import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
	const LoginScreen({super.key, required this.onCreateAccount});

	final VoidCallback onCreateAccount;

	@override
	State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();
	final _authService = AuthService();
	bool _submitting = false;

	@override
	void dispose() {
		_emailController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	Future<void> _signIn() async {
		if (_submitting) return;

		final email = _emailController.text.trim();
		final password = _passwordController.text;

		if (email.isEmpty || password.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Enter email and password.')),
			);
			return;
		}

		setState(() => _submitting = true);
		try {
			await _authService.signInWithEmailPassword(email: email, password: password);

			final user = _authService.currentUser;
			if (user != null && !user.emailVerified) {
				await _authService.signOut();
				if (!mounted) return;
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(
						content: Text('Please verify your email first, then sign in.'),
					),
				);
				return;
			}
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Signed in successfully.')),
			);
		} on Exception catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Sign in failed: ${e.toString()}')),
			);
		} finally {
			if (mounted) setState(() => _submitting = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		return AuthScaffold(
			title: 'Welcome Back',
			subtitle: 'Sign in to keep brewing',
			footer: AuthFooter(
				leading: 'New here !!!?',
				action: 'Create the account',
				onTap: widget.onCreateAccount,
			),
			children: [
				EmailField(controller: _emailController),
				const SizedBox(height: 22),
				PasswordField(controller: _passwordController),
				const SizedBox(height: 8),
				const Align(
					alignment: Alignment.centerRight,
					child: Text(
						'Forgot?',
						style: TextStyle(
							color: Color(0xFF75835F),
							fontSize: 18,
							fontWeight: FontWeight.w400,
						),
					),
				),
				const SizedBox(height: 34),
				PrimaryButton(
					label: _submitting ? 'Signing In…' : 'Sign In',
					onPressed: _submitting ? null : _signIn,
				),
				const SizedBox(height: 24),
			],
		);
	}
}

