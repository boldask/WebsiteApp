import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../services/database_service.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';

/// News/blog listing page that fetches articles from Firebase.
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _newsArticles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final articles = await _databaseService.getNews(limit: 20);
      setState(() {
        _newsArticles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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
                    _buildNewsContent(context, isWideScreen),
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
      child: Column(
        children: [
          Text(
            'News & Updates',
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
              'Stay up to date with the latest features, community highlights, '
              'and insights from the Boldask team.',
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

  Widget _buildNewsContent(BuildContext context, bool isWideScreen) {
    final padding = isWideScreen ? 80.0 : 24.0;

    if (_isLoading) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
        child: const LoadingIndicator(message: 'Loading news...'),
      );
    }

    if (_error != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
        child: EmptyState(
          icon: Icons.error_outline,
          title: 'Failed to load news',
          message: 'Please try again later.',
          actionLabel: 'Retry',
          onAction: _loadNews,
        ),
      );
    }

    if (_newsArticles.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
        child: const EmptyState(
          icon: Icons.article_outlined,
          title: 'No News Yet',
          message: 'Check back soon for updates and announcements.',
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured article (first one)
          if (_newsArticles.isNotEmpty)
            _buildFeaturedArticle(context, _newsArticles.first, isWideScreen),
          const SizedBox(height: 48),

          // Other articles in grid
          if (_newsArticles.length > 1) ...[
            Text(
              'More Articles',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWideScreen ? 3 : 1,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: isWideScreen ? 0.85 : 1.2,
              ),
              itemCount: _newsArticles.length - 1,
              itemBuilder: (context, index) => _buildArticleCard(
                context,
                _newsArticles[index + 1],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturedArticle(
    BuildContext context,
    Map<String, dynamic> article,
    bool isWideScreen,
  ) {
    final theme = Theme.of(context);
    final title = article['title'] ?? 'Untitled';
    final summary = article['summary'] ?? '';
    final imageUrl = article['imageUrl'];
    final publishedAt = article['publishedAt'] as Timestamp?;
    final category = article['category'] ?? 'General';

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showArticleDetail(context, article),
        child: isWideScreen
            ? SizedBox(
                height: 350,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildArticleImage(imageUrl),
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildFeaturedContent(
                        theme,
                        title,
                        summary,
                        publishedAt,
                        category,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 200,
                    child: _buildArticleImage(imageUrl),
                  ),
                  _buildFeaturedContent(
                    theme,
                    title,
                    summary,
                    publishedAt,
                    category,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildArticleImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: BoldaskColors.secondary.withOpacity(0.2),
      child: const Center(
        child: Icon(
          Icons.article_outlined,
          size: 64,
          color: BoldaskColors.secondary,
        ),
      ),
    );
  }

  Widget _buildFeaturedContent(
    ThemeData theme,
    String title,
    String summary,
    Timestamp? publishedAt,
    String category,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: BoldaskColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              category.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: BoldaskColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 6),
              Text(
                publishedAt != null
                    ? DateFormat('MMM d, yyyy').format(publishedAt.toDate())
                    : 'Recently',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const Spacer(),
              Text(
                'Read more',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: BoldaskColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: BoldaskColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Map<String, dynamic> article) {
    final theme = Theme.of(context);
    final title = article['title'] ?? 'Untitled';
    final summary = article['summary'] ?? '';
    final imageUrl = article['imageUrl'];
    final publishedAt = article['publishedAt'] as Timestamp?;
    final category = article['category'] ?? 'General';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showArticleDetail(context, article),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: _buildArticleImage(imageUrl),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: BoldaskColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: BoldaskColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        summary,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      publishedAt != null
                          ? DateFormat('MMM d, yyyy').format(publishedAt.toDate())
                          : 'Recently',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArticleDetail(BuildContext context, Map<String, dynamic> article) {
    final theme = Theme.of(context);
    final title = article['title'] ?? 'Untitled';
    final content = article['content'] ?? article['summary'] ?? '';
    final imageUrl = article['imageUrl'];
    final publishedAt = article['publishedAt'] as Timestamp?;
    final category = article['category'] ?? 'General';
    final author = article['author'] ?? 'Boldask Team';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              if (imageUrl != null && imageUrl.isNotEmpty)
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: BoldaskColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: BoldaskColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'By $author',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            publishedAt != null
                                ? DateFormat('MMMM d, yyyy').format(publishedAt.toDate())
                                : 'Recently',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Close button
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
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
