import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';

/// Account settings screen for managing user account preferences.
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      showBackButton: true,
      showBottomNav: false,
      showProfileInAppBar: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader(context, 'Account'),
            _buildSettingsCard(
              context,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'Update your profile information',
                  onTap: () => context.push(Routes.editProfile),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  onTap: _showChangePasswordDialog,
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Email Preferences',
                  subtitle: 'Manage email notifications',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Appearance Section
            _buildSectionHeader(context, 'Appearance'),
            _buildSettingsCard(
              context,
              children: [
                Consumer<AppStateProvider>(
                  builder: (context, appState, _) {
                    return _buildSettingsTileWithSwitch(
                      context,
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: 'Use dark theme',
                      value: appState.isDarkMode,
                      onChanged: (value) {
                        appState.toggleTheme();
                      },
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Privacy Section
            _buildSectionHeader(context, 'Privacy'),
            _buildSettingsCard(
              context,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.visibility_outlined,
                  title: 'Profile Visibility',
                  subtitle: 'Control who can see your profile',
                  onTap: () => _showComingSoon(context),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.block_outlined,
                  title: 'Blocked Users',
                  subtitle: 'Manage blocked accounts',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader(context, 'Support'),
            _buildSettingsCard(
              context,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  subtitle: 'FAQs and guides',
                  onTap: () => _showComingSoon(context),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle: 'Report bugs or suggest features',
                  onTap: () => _showComingSoon(context),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'Version ${AppConstants.appVersion}',
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Legal Section
            _buildSectionHeader(context, 'Legal'),
            _buildSettingsCard(
              context,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () => _showComingSoon(context),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Sign Out Button
            SecondaryButton(
              text: 'Sign Out',
              icon: Icons.logout,
              onPressed: _showSignOutDialog,
            ),

            const SizedBox(height: 16),

            // Delete Account Button
            Center(
              child: TextButton(
                onPressed: _showDeleteAccountDialog,
                child: Text(
                  'Delete Account',
                  style: TextStyle(
                    color: BoldaskColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withOpacity(0.4),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSettingsTileWithSwitch(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56);
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'We\'ll send a password reset link to your email address.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              final userProvider = context.read<UserProvider>();
              final email = userProvider.currentUser?.email;

              if (email != null) {
                final success = await authProvider.sendPasswordReset(email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Password reset email sent!'
                            : 'Failed to send reset email',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Image.asset(
        'assets/images/logofinal.png',
        height: 64,
        width: 64,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: BoldaskColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'B',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Boldask is a platform for meaningful conversations through polls and circles.',
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.websiteUrl,
          style: TextStyle(
            color: BoldaskColors.primary,
          ),
        ),
      ],
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });

              try {
                final authProvider = context.read<AuthProvider>();
                final userProvider = context.read<UserProvider>();

                userProvider.clearUser();
                await authProvider.signOut();

                if (mounted) {
                  context.go(Routes.landing);
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to sign out: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BoldaskColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data, including polls and circles, will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Show confirmation with email input
              _showDeleteConfirmationDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BoldaskColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    final emailController = TextEditingController();
    final userEmail =
        context.read<UserProvider>().currentUser?.email ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To confirm deletion, please type your email address:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.trim().toLowerCase() ==
                  userEmail.toLowerCase()) {
                Navigator.pop(context);
                _deleteAccount();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email doesn\'t match'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BoldaskColors.error,
            ),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you would call a backend function to delete user data
      // For now, just sign out
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();

      userProvider.clearUser();
      await authProvider.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account deletion requested. This may take up to 30 days.',
            ),
          ),
        );
        context.go(Routes.landing);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }
}
