import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/circle_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/cards/circle_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_widget.dart';

/// Screen for displaying circles created by the current user.
class OwnCirclesScreen extends StatefulWidget {
  const OwnCirclesScreen({super.key});

  @override
  State<OwnCirclesScreen> createState() => _OwnCirclesScreenState();
}

class _OwnCirclesScreenState extends State<OwnCirclesScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final ScrollController _scrollController = ScrollController();

  List<CircleModel> _circles = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCircles();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreCircles();
    }
  }

  Future<void> _loadCircles({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _circles = [];
        _hasMore = true;
      });
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId == null) {
        throw Exception('You must be logged in to view your circles');
      }

      final circles = await _databaseService.getCirclesByCreator(userId);

      setState(() {
        _circles = circles;
        _hasMore = circles.length >= 50;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreCircles() async {
    if (_isLoadingMore || !_hasMore || _circles.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId == null) return;

      // In a real implementation, you'd use pagination with startAfter
      final circles = await _databaseService.getCirclesByCreator(userId);

      setState(() {
        _hasMore = circles.length >= 50;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Circles'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/circles/create'),
            tooltip: 'Create Circle',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Loading your circles...');
    }

    if (_error != null) {
      return BoldaskErrorWidget(
        message: _error!,
        onRetry: () => _loadCircles(refresh: true),
      );
    }

    if (_circles.isEmpty) {
      return EmptyState(
        icon: Icons.groups_outlined,
        title: 'No Circles Yet',
        message:
            'You haven\'t created any circles yet. Create your first circle to start connecting with others!',
        actionLabel: 'Create Circle',
        onAction: () => context.push('/circles/create'),
      );
    }

    // Separate upcoming and past circles
    final now = DateTime.now();
    final upcomingCircles =
        _circles.where((c) => c.scheduledDate.isAfter(now)).toList();
    final pastCircles =
        _circles.where((c) => c.scheduledDate.isBefore(now)).toList();

    return RefreshIndicator(
      onRefresh: () => _loadCircles(refresh: true),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Upcoming circles section
          if (upcomingCircles.isNotEmpty) ...[
            _SectionHeader(
              title: 'Upcoming',
              count: upcomingCircles.length,
            ),
            ...upcomingCircles.map((circle) {
              return _OwnCircleCard(
                circle: circle,
                onTap: () => context.push('/circles/${circle.id}'),
              );
            }),
          ],

          // Past circles section
          if (pastCircles.isNotEmpty) ...[
            _SectionHeader(
              title: 'Past',
              count: pastCircles.length,
            ),
            ...pastCircles.map((circle) {
              return _OwnCircleCard(
                circle: circle,
                isPast: true,
                onTap: () => context.push('/circles/${circle.id}'),
              );
            }),
          ],

          // Loading more indicator
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

/// Section header widget.
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom circle card that shows creator badge and attendee count.
class _OwnCircleCard extends StatelessWidget {
  final CircleModel circle;
  final bool isPast;
  final VoidCallback? onTap;

  const _OwnCircleCard({
    required this.circle,
    this.isPast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Opacity(
          opacity: isPast ? 0.7 : 1.0,
          child: CircleCard(
            circle: circle,
            onTap: onTap,
          ),
        ),
        Positioned(
          top: 16,
          right: 24,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Host',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPast) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Past',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
