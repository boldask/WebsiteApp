import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/buttons/primary_button.dart';

/// Coming Soon placeholder screen for the Projects feature.
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Projects',
      showBackButton: true,
      showBottomNav: true,
      bottomNavIndex: 0,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with animation placeholder
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      BoldaskColors.primary.withOpacity(0.1),
                      BoldaskColors.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(
                  Icons.rocket_launch_outlined,
                  size: 80,
                  color: BoldaskColors.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Projects Coming Soon',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: BoldaskColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Text(
                  'We\'re working on an exciting new feature that will let you '
                  'collaborate on community projects and initiatives.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // Features preview
              _buildFeaturePreview(context),
              const SizedBox(height: 40),

              // CTA buttons
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  SecondaryButton(
                    text: 'Explore Polls',
                    isExpanded: false,
                    icon: Icons.poll_outlined,
                    onPressed: () => context.go('${Routes.home}?tab=0'),
                  ),
                  SecondaryButton(
                    text: 'Join Circles',
                    isExpanded: false,
                    icon: Icons.groups_outlined,
                    onPressed: () => context.go('${Routes.home}?tab=1'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Notification signup hint
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: BoldaskColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: BoldaskColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.notifications_active_outlined,
                      color: BoldaskColors.info,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'We\'ll notify you when Projects launches!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: BoldaskColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePreview(BuildContext context) {
    final theme = Theme.of(context);

    final features = [
      _FeatureItem(
        icon: Icons.group_work_outlined,
        title: 'Team Collaboration',
        description: 'Work together on meaningful initiatives',
      ),
      _FeatureItem(
        icon: Icons.timeline_outlined,
        title: 'Project Tracking',
        description: 'Set goals and track progress',
      ),
      _FeatureItem(
        icon: Icons.public_outlined,
        title: 'Community Impact',
        description: 'Make a difference in your community',
      ),
    ];

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        children: [
          Text(
            'What to Expect',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFeatureRow(theme, feature),
              )),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(ThemeData theme, _FeatureItem feature) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: BoldaskColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            feature.icon,
            size: 24,
            color: BoldaskColors.secondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                feature.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Feature item data class.
class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
