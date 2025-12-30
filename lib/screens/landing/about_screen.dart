import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';

/// About Boldask page with mission, team, and company information.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 800;
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, isWideScreen),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildHeroSection(context, isWideScreen),
                    _buildMissionSection(context, isWideScreen),
                    _buildValuesSection(context, isWideScreen),
                    _buildTeamSection(context, isWideScreen),
                    _buildStorySection(context, isWideScreen),
                    _buildCTASection(context, isWideScreen),
                    _buildFooter(context, isWideScreen),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);

    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 70,
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go(Routes.landing),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(
          horizontal: isWideScreen ? 48 : 16,
          vertical: 12,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 48), // Space for back button
            GestureDetector(
              onTap: () => context.go(Routes.landing),
              child: Image.asset(
                'assets/images/logofinal.png',
                height: 36,
                fit: BoxFit.fitHeight,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    'Boldask',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: BoldaskColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            if (isWideScreen)
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => context.push(Routes.login),
                    child: const Text('Login'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => context.push(Routes.join),
                    child: const Text('Get Started'),
                  ),
                ],
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);
    final padding = isWideScreen ? 80.0 : 24.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            BoldaskColors.primary,
            BoldaskColors.primaryLight,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'About Boldask',
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'We believe in the power of questions to connect people, '
              'challenge assumptions, and drive meaningful change.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);
    final padding = isWideScreen ? 80.0 : 24.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
      child: isWideScreen
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildMissionCard(
                    theme,
                    'Our Mission',
                    'To create a space where everyone feels empowered to ask bold '
                        'questions and engage in honest, thoughtful conversations that '
                        'expand perspectives and deepen understanding.',
                    Icons.flag_outlined,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: _buildMissionCard(
                    theme,
                    'Our Vision',
                    'A world where curiosity is celebrated, diverse viewpoints are '
                        'respected, and meaningful dialogue bridges divides and builds '
                        'stronger communities.',
                    Icons.visibility_outlined,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _buildMissionCard(
                  theme,
                  'Our Mission',
                  'To create a space where everyone feels empowered to ask bold '
                      'questions and engage in honest, thoughtful conversations that '
                      'expand perspectives and deepen understanding.',
                  Icons.flag_outlined,
                ),
                const SizedBox(height: 24),
                _buildMissionCard(
                  theme,
                  'Our Vision',
                  'A world where curiosity is celebrated, diverse viewpoints are '
                      'respected, and meaningful dialogue bridges divides and builds '
                      'stronger communities.',
                  Icons.visibility_outlined,
                ),
              ],
            ),
    );
  }

  Widget _buildMissionCard(ThemeData theme, String title, String description, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BoldaskColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: BoldaskColors.secondary, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValuesSection(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);
    final padding = isWideScreen ? 80.0 : 24.0;

    final values = [
      _ValueItem(
        title: 'Curiosity',
        description: 'We embrace questions as the starting point for growth and understanding.',
        icon: Icons.lightbulb_outline,
      ),
      _ValueItem(
        title: 'Authenticity',
        description: 'We encourage genuine expression and honest dialogue.',
        icon: Icons.favorite_outline,
      ),
      _ValueItem(
        title: 'Respect',
        description: 'We value diverse perspectives and treat all voices with dignity.',
        icon: Icons.handshake_outlined,
      ),
      _ValueItem(
        title: 'Community',
        description: 'We build connections that support, challenge, and inspire.',
        icon: Icons.people_outline,
      ),
      _ValueItem(
        title: 'Courage',
        description: 'We champion the boldness to ask difficult questions.',
        icon: Icons.shield_outlined,
      ),
      _ValueItem(
        title: 'Growth',
        description: 'We believe in the power of learning from different viewpoints.',
        icon: Icons.trending_up,
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
      color: BoldaskColors.primary.withOpacity(0.03),
      child: Column(
        children: [
          Text(
            'Our Values',
            style: theme.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'The principles that guide everything we do.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWideScreen ? 3 : 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: isWideScreen ? 1.3 : 1.1,
            ),
            itemCount: values.length,
            itemBuilder: (context, index) => _buildValueCard(theme, values[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard(ThemeData theme, _ValueItem value) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(value.icon, size: 36, color: BoldaskColors.primary),
            const SizedBox(height: 12),
            Text(
              value.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);
    final padding = isWideScreen ? 80.0 : 24.0;

    final team = [
      _TeamMember(
        name: 'Alex Johnson',
        role: 'Founder & CEO',
        bio: 'Passionate about building communities through meaningful conversations.',
      ),
      _TeamMember(
        name: 'Jordan Lee',
        role: 'Head of Product',
        bio: 'Designing experiences that bring people together.',
      ),
      _TeamMember(
        name: 'Sam Rivera',
        role: 'Head of Community',
        bio: 'Fostering connections and ensuring every voice is heard.',
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
      child: Column(
        children: [
          Text(
            'Meet the Team',
            style: theme.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'The people behind Boldask.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          isWideScreen
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: team
                      .map((member) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildTeamMemberCard(theme, member),
                          ))
                      .toList(),
                )
              : Column(
                  children: team
                      .map((member) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildTeamMemberCard(theme, member),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(ThemeData theme, _TeamMember member) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: BoldaskColors.secondary.withOpacity(0.2),
                child: Text(
                  member.name.split(' ').map((n) => n[0]).join(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: BoldaskColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                member.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                member.role,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: BoldaskColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                member.bio,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStorySection(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);
    final padding = isWideScreen ? 80.0 : 24.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
      color: BoldaskColors.primary.withOpacity(0.03),
      child: Column(
        children: [
          Text(
            'Our Story',
            style: theme.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildStoryParagraph(
                  theme,
                  'Boldask was born from a simple observation: the best conversations '
                  'happen when someone has the courage to ask a bold question. Whether '
                  'it\'s about personal growth, social issues, or life\'s big questions, '
                  'we noticed that authentic discussions often start with curiosity.',
                ),
                const SizedBox(height: 20),
                _buildStoryParagraph(
                  theme,
                  'In 2023, we set out to create a platform that celebrates this '
                  'spirit of inquiry. We wanted to build a community where asking '
                  'questions is encouraged, diverse perspectives are valued, and '
                  'meaningful connections form naturally.',
                ),
                const SizedBox(height: 20),
                _buildStoryParagraph(
                  theme,
                  'Today, Boldask is home to thousands of curious minds sharing polls, '
                  'joining circles, and engaging in conversations that matter. We\'re '
                  'just getting started, and we invite you to be part of our journey.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryParagraph(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.8),
        height: 1.7,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCTASection(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);
    final padding = isWideScreen ? 80.0 : 24.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BoldaskColors.primary,
            BoldaskColors.primaryLight,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Join Our Community',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Be part of a community that values curiosity and conversation.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => context.push(Routes.join),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: BoldaskColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                ),
                child: const Text('Get Started'),
              ),
              OutlinedButton(
                onPressed: () => context.push(Routes.news),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                ),
                child: const Text('Read Our News'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);
    final padding = isWideScreen ? 80.0 : 24.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 40),
      color: BoldaskColors.backgroundDark,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => context.go(Routes.landing),
                child: Text(
                  'Home',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              TextButton(
                onPressed: () => context.push(Routes.news),
                child: Text(
                  'News',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              TextButton(
                onPressed: () => context.push(Routes.login),
                child: Text(
                  'Login',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '2024 Boldask. All rights reserved.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Value item data class.
class _ValueItem {
  final String title;
  final String description;
  final IconData icon;

  _ValueItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Team member data class.
class _TeamMember {
  final String name;
  final String role;
  final String bio;

  _TeamMember({
    required this.name,
    required this.role,
    required this.bio,
  });
}
