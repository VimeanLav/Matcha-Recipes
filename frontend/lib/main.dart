import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matcha Recipes',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C8A56),
          surface: const Color(0xFFFBFAF4),
        ),
        scaffoldBackgroundColor: const Color(0xFFFBFAF4),
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            height: 1.08,
            color: Color(0xFF263025),
          ),
          headlineMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6A7169),
          ),
        ),
      ),
      home: const AuthGateScreen(),
    );
  }
}

enum AuthMode { signIn, signUp }

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  AuthMode _mode = AuthMode.signIn;

  void _setMode(AuthMode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: _mode == AuthMode.signIn
          ? SignInScreen(
              key: const ValueKey('sign-in'),
              onCreateAccount: () => _setMode(AuthMode.signUp),
            )
          : SignUpScreen(
              key: const ValueKey('sign-up'),
              onSignIn: () => _setMode(AuthMode.signIn),
            ),
    );
  }
}

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key, required this.onCreateAccount});

  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Welcome Back',
      subtitle: 'Sign in to keep brewing',
      footer: _AuthFooter(
        leading: 'New here?',
        action: 'Create account',
        onTap: onCreateAccount,
      ),
      children: const [
        _EmailField(),
        SizedBox(height: 22),
        _PasswordField(),
        SizedBox(height: 8),
        Align(
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
        SizedBox(height: 34),
        _PrimaryButton(label: 'Sign In'),
        SizedBox(height: 24),
      ],
    );
  }
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key, required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Create account',
      subtitle: 'join the matcha community.',
      footer: _AuthFooter(
        leading: 'Already a member?',
        action: 'Sign in',
        onTap: onSignIn,
      ),
      children: const [
        _UsernameField(),
        SizedBox(height: 22),
        _EmailField(),
        SizedBox(height: 22),
        _PasswordField(),
        SizedBox(height: 18),
        _TermsRow(),
        SizedBox(height: 34),
        _PrimaryButton(label: 'Create account'),
        SizedBox(height: 24),
      ],
    );
  }
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    required this.footer,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 42),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _BrandMark(),
                      const SizedBox(height: 28),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 42),
                      ...children,
                      const Spacer(),
                      footer,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      width: 62,
      decoration: const BoxDecoration(
        color: Color(0xFFD9E7C1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.eco_outlined,
        size: 30,
        color: Color(0xFF3E5A34),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.hintText,
    required this.icon,
    this.obscureText = false,
  });

  final String hintText;
  final IconData icon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4E8),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: TextField(
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 17,
          color: Color(0xFF30372E),
        ),
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF70776C), size: 22),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF8A8F86),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 22),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    return const _AuthField(
      hintText: 'Email',
      icon: Icons.mail_outline_rounded,
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    return const _AuthField(
      hintText: 'Password',
      icon: Icons.lock_outline_rounded,
      obscureText: true,
    );
  }
}

class _UsernameField extends StatelessWidget {
  const _UsernameField();

  @override
  Widget build(BuildContext context) {
    return const _AuthField(
      hintText: 'Username',
      icon: Icons.person_outline_rounded,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 74,
      child: FilledButton(
        onPressed: () {},
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF6C8A56),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(38),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.check_circle_outline, color: Color(0xFF6C8A56), size: 24),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'I agree to term and Privacy Policy.',
            style: TextStyle(
              fontSize: 17,
              color: Color(0xFF63705D),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthFooter extends StatelessWidget {
  const _AuthFooter({required this.leading, required this.action, required this.onTap});

  final String leading;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF8591A0),
              ),
              children: [
                TextSpan(text: '$leading '),
                TextSpan(
                  text: action,
                  style: const TextStyle(
                    color: Color(0xFF3E5A34),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
