import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/forms/styled_text_field.dart';

/// Password reset screen for email-based password recovery.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordReset(
      _emailController.text.trim(),
    );

    if (success && mounted) {
      setState(() {
        _emailSent = true;
      });
    } else if (mounted && authProvider.error != null) {
      _showErrorSnackBar(authProvider.error!);
      authProvider.clearError();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessContent() : _buildResetForm(),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    final theme = Theme.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Icon
              Icon(
                Icons.lock_reset,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Forgot your password?',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Email field
              EmailTextField(
                controller: _emailController,
                autofocus: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              // Submit button
              PrimaryButton(
                text: 'Send Reset Link',
                isLoading: authProvider.isLoading,
                onPressed: _handlePasswordReset,
              ),
              const SizedBox(height: 16),

              // Back to login link
              TextButton(
                onPressed: () => context.go(Routes.login),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuccessContent() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),

        // Success icon
        Icon(
          Icons.mark_email_read,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 32),

        // Title
        Text(
          'Check your email',
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          'We\'ve sent a password reset link to:',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Email address
        Text(
          _emailController.text.trim(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildInstructionItem(
                theme,
                '1',
                'Check your email inbox',
              ),
              const SizedBox(height: 12),
              _buildInstructionItem(
                theme,
                '2',
                'Click the reset link in the email',
              ),
              const SizedBox(height: 12),
              _buildInstructionItem(
                theme,
                '3',
                'Create a new password',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Resend button
        SecondaryButton(
          text: 'Resend Email',
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
        ),
        const SizedBox(height: 16),

        // Back to login button
        PrimaryButton(
          text: 'Back to Login',
          onPressed: () => context.go(Routes.login),
        ),
        const SizedBox(height: 24),

        // Spam notice
        Text(
          'Didn\'t receive the email? Check your spam folder.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInstructionItem(ThemeData theme, String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
