import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Login screen wired to [AuthController].
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _signInWithEmail() async {
    await ref.read(authControllerProvider.notifier).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final isDark = theme.brightness == Brightness.dark;

    // Show error snackbars.
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),

              // ── Header ──────────────────────────────────────────────
              Center(
                child: Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.5)
                          : AppColors.saffron.withValues(alpha: 0.2),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
  child: Padding(
    padding: const EdgeInsets.all(1.0), // adjust as needed
                  child: Image.asset(
                    'assets/images/logo/7.png',
      fit: BoxFit.fill,
    ),
  ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Welcome to GOAT',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to discover temples near you',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),

              // ── Form ─────────────────────────────────────────────────
              CustomTextField(
                label: 'Email',
                hint: 'you@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(Icons.email_outlined,
                    color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _signInWithEmail(),
                prefixIcon: Icon(Icons.lock_outline,
                    color: theme.colorScheme.onSurfaceVariant),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: Text(
                    'Forgot Password?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Sign In',
                isLoading: isLoading,
                onPressed: _signInWithEmail,
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Create Account',
                isOutlined: true,
                onPressed: () => context.push('/sign-up'),
              ),

              const SizedBox(height: 32),

              // ── Divider ──────────────────────────────────────────────
              Row(children: [
                Expanded(
                    child: Divider(color: theme.colorScheme.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('or continue with',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ),
                Expanded(
                    child: Divider(color: theme.colorScheme.outlineVariant)),
              ]),

              const SizedBox(height: 24),

              // ── Social Buttons ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialButton(
                    icon: Icons.g_mobiledata,
                    label: 'Google',
                    onTap: isLoading ? null : _signInWithGoogle,
                  ),
                  const SizedBox(width: 16),
                  _SocialButton(
                    icon: Icons.phone_android,
                    label: 'Phone',
                    onTap: () {}, // TODO: phone auth
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Social button ────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SocialButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.onSurface),
            const SizedBox(width: 8),
            Text(label,
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
