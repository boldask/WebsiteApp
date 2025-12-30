import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';

/// Main application widget for Boldask.
/// Configures theme, routing, and global app settings.
class BoldaskApp extends StatelessWidget {
  const BoldaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return MaterialApp.router(
      title: 'Boldask',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: BoldaskTheme.lightTheme,
      darkTheme: BoldaskTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Router configuration
      routerConfig: AppRouter.router(authProvider),
    );
  }
}
