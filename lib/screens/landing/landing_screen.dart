import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';

/// Marketing landing page with hero section, features, and CTAs.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

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
                    _buildFeaturesSection(context, isWideScreen),
                    _buildStatsSection(context, isWideScreen),
                    _buildTestimonialsSection(context, isWideScreen),
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
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(
          horizontal: isWideScreen ? 48 : 16,
          vertical: 12,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
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

            // Navigation
            if (isWideScreen)
              Row(
                children: [
                  _NavLink(
                    label: 'About',
                    onTap: () => context.push(Routes.about),
                  ),
                  const SizedBox(width: 24),
                  _NavLink(
                    label: 'News',
                    onTap: () => context.push(Routes.news),
                  ),
                  const SizedBox(width: 32),
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu),
                onSelected: (value) {
                  switch (value) {
                    case 'about':
                      context.push(Routes.about);
                      break;
                    case 'news':
                      context.push(Routes.news);
                      break;
                    case 'login':
                      context.push(Routes.login);
                      break;
                    case 'join':
                      context.push(Routes.join);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'about', child: Text('About')),
                  const PopupMenuItem(value: 'news', child: Text('News')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'login', child: Text('Login')),
                  const PopupMenuItem(value: 'join', child: Text('Get Started')),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);
    final padding = isWideScreen ? 80.0 : 24.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 60),
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
      child: isWideScreen
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildHeroContent(context, theme),
                ),
                const SizedBox(width: 60),
                Expanded(
                  child: _buildHeroImage(context),
                ),
              ],
            )
          : Column(
              children: [
                _buildHeroContent(context, theme),
                const SizedBox(height: 40),
                _buildHeroImage(context),
              ],
            ),
    );
  }

  Widget _buildHeroContent(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ask Bold Questions.',
          style: theme.textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connect Through Conversations.',
          style: theme.textTheme.displaySmall?.copyWith(
            color: BoldaskColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Boldask is a community platform where meaningful questions spark '
          'authentic discussions. Create polls, join circles, and discover '
          'perspectives that challenge and inspire you.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () => context.push(Routes.join),
              style: ElevatedButton.styleFrom(
                backgroundColor: BoldaskColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              ),
              child: const Text('Join Boldask'),
            ),
            OutlinedButton(
              onPressed: () => context.push(Routes.about),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              ),
              child: const Text('Learn More'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/hero_illustration.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 300,
              decoration: BoxDecoration(
                color: BoldaskColors.secondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.question_answer_outlined,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);
    final padding = isWideScreen ? 80.0 : 24.0;

    final features = [
      _FeatureItem(
        icon: Icons.poll_outlined,
        title: 'Create Polls',
        description: 'Ask questions that matter. Get authentic responses from the community.',
        color: BoldaskColors.info,
      ),
      _FeatureItem(
        icon: Icons.groups_outlined,
        title: 'Join Circles',
        description: 'Connect with like-minded people through topic-based discussion groups.',
        color: BoldaskColors.success,
      ),
      _FeatureItem(
        icon: Icons.explore_outlined,
        title: 'Discover Perspectives',
        description: 'Explore diverse viewpoints and challenge your own thinking.',
        color: BoldaskColors.warning,
      ),
      _FeatureItem(
        icon: Icons.rocket_launch_outlined,
        title: 'Projects (Coming Soon)',
        description: 'Collaborate on initiatives that make a difference in your community.',
        color: BoldaskColors.secondary,
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
      child: Column(
        children: [
          Text(
            'Everything You Need to Connect',
            style: theme.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Boldask provides the tools to foster meaningful conversations.',
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
              crossAxisCount: isWideScreen ? 4 : 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: isWideScreen ? 0.9 : 0.85,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) => _buildFeatureCard(context, features[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureItem feature) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feature.icon,
                size: 40,
                color: feature.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              feature.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              feature.description,
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

  Widget _buildStatsSection(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);
    final padding = isWideScreen ? 80.0 : 24.0;

    final stats = [
      _StatItem(value: '10K+', label: 'Active Users'),
      _StatItem(value: '50K+', label: 'Polls Created'),
      _StatItem(value: '5K+', label: 'Circles'),
      _StatItem(value: '1M+', label: 'Conversations'),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 60),
      decoration: BoxDecoration(
        color: BoldaskColors.primary.withOpacity(0.05),
      ),
      child: isWideScreen
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: stats.map((stat) => _buildStatItem(theme, stat)).toList(),
            )
          : GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2,
              children: stats.map((stat) => _buildStatItem(theme, stat)).toList(),
            ),
    );
  }

  Widget _buildStatItem(ThemeData theme, _StatItem stat) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          stat.value,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: BoldaskColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialsSection(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);
    final padding = isWideScreen ? 80.0 : 24.0;

    final testimonials = [
      _TestimonialItem(
        quote: 'Boldask helped me discover perspectives I never considered. The community is incredibly thoughtful and engaging.',
        author: 'Sarah M.',
        role: 'Community Leader',
      ),
      _TestimonialItem(
        quote: 'I love how easy it is to start meaningful conversations. Circles have become my favorite way to connect with like-minded people.',
        author: 'James T.',
        role: 'Educator',
      ),
      _TestimonialItem(
        quote: 'Finally, a platform where questions matter. Boldask has changed how I engage with important topics.',
        author: 'Maria L.',
        role: 'Social Advocate',
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
      child: Column(
        children: [
          Text(
            'What Our Community Says',
            style: theme.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          isWideScreen
              ? Row(
                  children: testimonials
                      .map((t) => Expanded(child: _buildTestimonialCard(theme, t)))
                      .toList(),
                )
              : Column(
                  children: testimonials
                      .map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildTestimonialCard(theme, t),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(ThemeData theme, _TestimonialItem testimonial) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.format_quote,
              size: 32,
              color: BoldaskColors.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              testimonial.quote,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              testimonial.author,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              testimonial.role,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
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
            'Ready to Ask Bold Questions?',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Join thousands of people having meaningful conversations.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push(Routes.join),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: BoldaskColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            ),
            child: const Text('Get Started for Free'),
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
          if (isWideScreen)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildFooterBrand(theme)),
                Expanded(child: _buildFooterLinks(context, theme, 'Product', ['Polls', 'Circles', 'Projects'])),
                Expanded(child: _buildFooterLinks(context, theme, 'Company', ['About', 'News', 'Contact'])),
                Expanded(child: _buildFooterLinks(context, theme, 'Legal', ['Privacy', 'Terms', 'Cookies'])),
              ],
            )
          else
            Column(
              children: [
                _buildFooterBrand(theme),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildFooterLinks(context, theme, 'Product', ['Polls', 'Circles'])),
                    Expanded(child: _buildFooterLinks(context, theme, 'Company', ['About', 'News'])),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 32),
          Divider(color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            '2024 Boldask. All rights reserved.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterBrand(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Boldask',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ask bold questions.\nConnect through conversations.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLinks(BuildContext context, ThemeData theme, String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  // Navigate based on link
                  if (link == 'About') context.push(Routes.about);
                  if (link == 'News') context.push(Routes.news);
                },
                child: Text(
                  link,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

/// Navigation link widget.
class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

/// Feature item data class.
class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

/// Stat item data class.
class _StatItem {
  final String value;
  final String label;

  _StatItem({required this.value, required this.label});
}

/// Testimonial item data class.
class _TestimonialItem {
  final String quote;
  final String author;
  final String role;

  _TestimonialItem({
    required this.quote,
    required this.author,
    required this.role,
  });
}
