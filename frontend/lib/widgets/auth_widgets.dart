import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 42,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BrandMark(),
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

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

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.hintText,
    required this.icon,
    this.controller,
    this.obscureText = false,
  });

  final String hintText;
  final IconData icon;
  final TextEditingController? controller;
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
        controller: controller,
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

class EmailField extends StatelessWidget {
  const EmailField({super.key, this.controller});

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return AuthField(
      hintText: 'Email',
      icon: Icons.mail_outline_rounded,
      controller: controller,
    );
  }
}

class PasswordField extends StatelessWidget {
  const PasswordField({super.key, this.controller, this.hintText = 'Password'});

  final TextEditingController? controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return AuthField(
      hintText: hintText,
      icon: Icons.lock_outline_rounded,
      obscureText: true,
      controller: controller,
    );
  }
}

class UsernameField extends StatelessWidget {
  const UsernameField({super.key, this.controller});

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return AuthField(
      hintText: 'Username',
      icon: Icons.person_outline_rounded,
      controller: controller,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 74,
      child: FilledButton(
        onPressed: onPressed,
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

class TermsRow extends StatelessWidget {
  const TermsRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            shape: const CircleBorder(),
            activeColor: const Color(0xFF6C8A56),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'I agree to term and Privacy Policy.',
            style: const TextStyle(
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

class AuthFooter extends StatefulWidget {
  const AuthFooter({
    super.key,
    required this.leading,
    required this.action,
    required this.onTap,
  });

  final String leading;
  final String action;
  final VoidCallback? onTap;

  @override
  State<AuthFooter> createState() => _AuthFooterState();
}

class _AuthFooterState extends State<AuthFooter> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF8591A0),
                ),
                children: [
                  TextSpan(text: '${widget.leading} '),
                  TextSpan(
                    text: widget.action,
                    style: TextStyle(
                      color: const Color(0xFF3E5A34),
                      fontWeight: FontWeight.w700,
                      decoration: _hover ? TextDecoration.underline : TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
