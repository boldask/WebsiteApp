import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';

/// Call to action page to sign up for Boldask.
class JoinScreen extends StatelessWidget {
  const JoinScreen({super.key});

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
                    _buildBenefitsSection(context, isWideScreen),
                    _buildHowItWorksSection(context, isWideScreen),
                    _buildSignUpCTASection(context, isWideScreen),
                    _buildFAQSection(context, isWideScreen),
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
            const SizedBox(width: 48),
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
              TextButton(
                onPressed: () => context.push(Routes.login),
                child: const Text('Already have an account? Login'),
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
            'Join Boldask Today',
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
              'Start asking bold questions and connect with a community that '
              'values meaningful conversations.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push(Routes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: BoldaskColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            ),
            child: const Text('Create Free Account'),
          ),
          const SizedBox(height: 16),
          Text(
            'Free forever. No credit card required.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);
    final padding = isWideScreen ? 80.0 : 24.0;

    final benefits = [
      _BenefitItem(
        icon: Icons.poll_outlined,
        title: 'Create Unlimited Polls',
        description: 'Ask questions that matter and get authentic responses from the community.',
      ),
      _BenefitItem(
        icon: Icons.groups_outlined,
        title: 'Join & Create Circles',
        description: 'Connect with like-minded people through topic-based discussion groups.',
      ),
      _BenefitItem(
        icon: Icons.person_add_outlined,
        title: 'Build Your Network',
        description: 'Follow interesting people and grow your community of curious minds.',
      ),
      _BenefitItem(
        icon: Icons.explore_outlined,
        title: 'Discover Perspectives',
        description: 'Explore diverse viewpoints that challenge and expand your thinking.',
      ),
      _BenefitItem(
        icon: Icons.favorite_outline,
        title: 'Save Favorites',
        description: 'Bookmark polls and circles that resonate with you for easy access.',
      ),
      _BenefitItem(
        icon: Icons.notifications_outlined,
        title: 'Stay Updated',
        description: 'Get notified about new activity from people and topics you follow.',
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
      child: Column(
        children: [
          Text(
            'Why Join Boldask?',
            style: theme.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Everything you need to engage in meaningful conversations.',
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
              childAspectRatio: isWideScreen ? 1.2 : 1.0,
            ),
            itemCount: benefits.length,
            itemBuilder: (context, index) => _buildBenefitCard(theme, benefits[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(ThemeData theme, _BenefitItem benefit) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BoldaskColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                benefit.icon,
                size: 32,
                color: BoldaskColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              benefit.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              benefit.description,
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

  Widget _buildHowItWorksSection(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);
    final padding = isWideScreen ? 80.0 : 24.0;

    final steps = [
      _StepItem(
        number: '1',
        title: 'Create Your Account',
        description: 'Sign up in seconds with your email. No credit card required.',
      ),
      _StepItem(
        number: '2',
        title: 'Set Up Your Profile',
        description: 'Tell us a bit about yourself and your interests.',
      ),
      _StepItem(
        number: '3',
        title: 'Start Exploring',
        description: 'Browse polls, join circles, and connect with the community.',
      ),
      _StepItem(
        number: '4',
        title: 'Ask Bold Questions',
        description: 'Create your own polls and spark meaningful conversations.',
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
      color: BoldaskColors.primary.withOpacity(0.03),
      child: Column(
        children: [
          Text(
            'How It Works',
            style: theme.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Get started in just a few simple steps.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          isWideScreen
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps.map((step) => Expanded(child: _buildStepItem(theme, step))).toList(),
                )
              : Column(
                  children: steps.map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: _buildStepItem(theme, step),
                  )).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildStepItem(ThemeData theme, _StepItem step) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: BoldaskColors.primary,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Center(
            child: Text(
              step.number,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          step.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(
            step.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpCTASection(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);
    final padding = isWideScreen ? 80.0 : 24.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
      child: Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                BoldaskColors.primary.withOpacity(0.05),
                BoldaskColors.secondary.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.rocket_launch_outlined,
                size: 64,
                color: BoldaskColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Ready to Get Started?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Text(
                  'Join thousands of curious minds who are already having '
                  'meaningful conversations on Boldask.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => context.push(Routes.login),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    ),
                    child: const Text('Create Free Account'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.push(Routes.about),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    ),
                    child: const Text('Learn More'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context, bool isWideScreen) {
    final theme = Theme.of(context);
    final padding = isWideScreen ? 80.0 : 24.0;

    final faqs = [
      _FAQItem(
        question: 'Is Boldask free to use?',
        answer: 'Yes! Boldask is completely free to use. Create an account and start '
            'exploring polls, circles, and connecting with the community at no cost.',
      ),
      _FAQItem(
        question: 'What can I do on Boldask?',
        answer: 'You can create and answer polls, join discussion circles, follow '
            'interesting people, save favorites, and engage in meaningful conversations '
            'about topics that matter to you.',
      ),
      _FAQItem(
        question: 'How do I get started?',
        answer: 'Simply create an account with your email, set up your profile, and '
            'start exploring. You can browse existing polls and circles, or create '
            'your own to start conversations.',
      ),
      _FAQItem(
        question: 'Is my data private?',
        answer: 'We take privacy seriously. Your personal information is secure, and '
            'you have control over what you share publicly. Check our privacy policy '
            'for more details.',
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
      color: BoldaskColors.primary.withOpacity(0.03),
      child: Column(
        children: [
          Text(
            'Frequently Asked Questions',
            style: theme.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: faqs.map((faq) => _buildFAQItem(theme, faq)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(ThemeData theme, _FAQItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Text(
          faq.question,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Text(
            faq.answer,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.6,
            ),
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
                onPressed: () => context.push(Routes.about),
                child: Text(
                  'About',
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

/// Benefit item data class.
class _BenefitItem {
  final IconData icon;
  final String title;
  final String description;

  _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// Step item data class.
class _StepItem {
  final String number;
  final String title;
  final String description;

  _StepItem({
    required this.number,
    required this.title,
    required this.description,
  });
}

/// FAQ item data class.
class _FAQItem {
  final String question;
  final String answer;

  _FAQItem({required this.question, required this.answer});
}
