import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/forms/styled_text_field.dart';

/// Login/Signup tabbed screen with email/password authentication.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Sign up controllers
  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpConfirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _loginEmailController.text.trim(),
      password: _loginPasswordController.text,
    );

    if (success && mounted) {
      context.go(Routes.home);
    } else if (mounted && authProvider.error != null) {
      _showErrorSnackBar(authProvider.error!);
      authProvider.clearError();
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.createAccount(
      email: _signUpEmailController.text.trim(),
      password: _signUpPasswordController.text,
      displayName: _signUpNameController.text.trim(),
    );

    if (success && mounted) {
      context.go(Routes.onboarding);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo
              Image.asset(
                'assets/images/logofinal.png',
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),

              // Welcome text
              Text(
                'Welcome to Boldask',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Connect, share, and discover',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Tab bar
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Login'),
                    Tab(text: 'Sign Up'),
                  ],
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 24),

              // Tab content
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginForm(),
                    _buildSignUpForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EmailTextField(
                controller: _loginEmailController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              PasswordTextField(
                controller: _loginPasswordController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 8),

              // Forgot password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(Routes.forgotPassword),
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 16),

              // Login button
              PrimaryButton(
                text: 'Login',
                isLoading: authProvider.isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 24),

              // Divider with "or"
              Row(
                children: [
                  Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                    ),
                  ),
                  Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                ],
              ),
              const SizedBox(height: 24),

              // Switch to sign up
              SecondaryButton(
                text: 'Create an Account',
                onPressed: () => _tabController.animateTo(1),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSignUpForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _signUpFormKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Display name field
                StyledTextField(
                  controller: _signUpNameController,
                  hintText: 'Display Name...',
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                EmailTextField(
                  controller: _signUpEmailController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                PasswordTextField(
                  controller: _signUpPasswordController,
                  hintText: 'Password (min 6 characters)...',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                PasswordTextField(
                  controller: _signUpConfirmPasswordController,
                  hintText: 'Confirm Password...',
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleSignUp(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _signUpPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Sign up button
                PrimaryButton(
                  text: 'Create Account',
                  isLoading: authProvider.isLoading,
                  onPressed: _handleSignUp,
                ),
                const SizedBox(height: 16),

                // Terms text
                Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
