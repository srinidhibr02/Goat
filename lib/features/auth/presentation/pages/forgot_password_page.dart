import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_providers.dart';

/// Forgot password screen — sends a reset link via [AuthController].
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final ok = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(_emailController.text.trim());
    if (ok && mounted) setState(() => _emailSent = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(authControllerProvider).isLoading;

    ref.listen<AsyncValue<void>>(authControllerProvider, (_, state) {
      if (state case AsyncError(:final error)) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text(error.toString()),
            backgroundColor: theme.colorScheme.error,
          ));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: _emailSent ? _SuccessView(email: _emailController.text) : _FormView(
            emailController: _emailController,
            isLoading: isLoading,
            onSubmit: _sendResetLink,
          ),
        ),
      ),
    );
  }
}

// ── Form ─────────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _FormView({
    required this.emailController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.lock_reset_outlined,
            size: 64, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text('Forgot your password?',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 40),
        CustomTextField(
          label: 'Email',
          hint: 'you@example.com',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmit(),
          prefixIcon: Icon(Icons.email_outlined,
              color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        CustomButton(
          text: 'Send Reset Link',
          isLoading: isLoading,
          icon: Icons.send_outlined,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

// ── Success ───────────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_read_outlined,
            size: 72, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text('Check your inbox',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text(
          'A password reset link has been sent to\n$email',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 40),
        CustomButton(
          text: 'Back to Sign In',
          isOutlined: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
