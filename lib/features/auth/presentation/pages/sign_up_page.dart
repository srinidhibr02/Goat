import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_providers.dart';

/// Sign-up screen wired to [AuthController].
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      return;
    }
    await ref.read(authControllerProvider.notifier).signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
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
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Display Name',
                  hint: 'Your name',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icon(Icons.person_outline,
                      color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),

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
                  hint: 'Min. 6 characters',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icon(Icons.lock_outline,
                      color: theme.colorScheme.onSurfaceVariant),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Confirm Password',
                  hint: '••••••••',
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  prefixIcon: Icon(Icons.lock_outline,
                      color: theme.colorScheme.onSurfaceVariant),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: 'Create Account',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Already have an account? Sign In',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
