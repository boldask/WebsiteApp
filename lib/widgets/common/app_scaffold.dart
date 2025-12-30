import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import 'bottom_nav.dart';

/// Reusable scaffold wrapper for authenticated screens.
/// Provides consistent app bar and bottom navigation.
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBackButton;
  final bool showBottomNav;
  final int? bottomNavIndex;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showProfileInAppBar;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton = false,
    this.showBottomNav = true,
    this.bottomNavIndex,
    this.actions,
    this.floatingActionButton,
    this.showProfileInAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.chevron_left, size: 30),
                onPressed: () => context.pop(),
              )
            : null,
        automaticallyImplyLeading: showBackButton,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Image.asset(
              'assets/images/logofinal.png',
              height: 40,
              fit: BoxFit.fitHeight,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  'Boldask',
                  style: Theme.of(context).textTheme.titleLarge,
                );
              },
            ),
            // Profile avatar or actions
            if (showProfileInAppBar && authProvider.isAuthenticated)
              _buildProfileAvatar(context, authProvider)
            else if (actions != null)
              Row(children: actions!),
          ],
        ),
        titleSpacing: 16,
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: showBottomNav
          ? BoldaskBottomNav(currentIndex: bottomNavIndex ?? 0)
          : null,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildProfileAvatar(BuildContext context, AuthProvider authProvider) {
    final photoUrl = authProvider.user?.photoURL;

    return GestureDetector(
      onTap: () => context.push(Routes.profile),
      child: photoUrl != null && photoUrl.isNotEmpty
          ? CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(photoUrl),
            )
          : const CircleAvatar(
              radius: 18,
              child: Icon(Icons.account_circle, size: 36),
            ),
    );
  }
}
