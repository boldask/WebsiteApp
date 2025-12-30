import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/poll_model.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart';
import '../../widgets/cards/poll_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_widget.dart';

/// Screen for displaying polls the current user has voted on.
class ParticipatedPollsScreen extends StatefulWidget {
  const ParticipatedPollsScreen({super.key});

  @override
  State<ParticipatedPollsScreen> createState() => _ParticipatedPollsScreenState();
}

class _ParticipatedPollsScreenState extends State<ParticipatedPollsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  List<PollModel> _polls = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _loadPolls();
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
      _loadMorePolls();
    }
  }

  Future<void> _loadPolls({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _polls = [];
        _hasMore = true;
        _lastDocument = null;
      });
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId == null) {
        throw Exception('You must be logged in to view participated polls');
      }

      // Query polls where the user has voted
      Query query = _firestore
          .collection(AppConstants.pollsCollection)
          .where('votedUserIds', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .limit(20);

      final snapshot = await query.get();

      final polls = snapshot.docs
          .map((doc) => PollModel.fromFirestore(doc))
          .toList();

      setState(() {
        _polls = polls;
        _hasMore = polls.length >= 20;
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePolls() async {
    if (_isLoadingMore || !_hasMore || _lastDocument == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId == null) return;

      Query query = _firestore
          .collection(AppConstants.pollsCollection)
          .where('votedUserIds', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(20);

      final snapshot = await query.get();

      final newPolls = snapshot.docs
          .map((doc) => PollModel.fromFirestore(doc))
          .toList();

      setState(() {
        _polls.addAll(newPolls);
        _hasMore = newPolls.length >= 20;
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
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
        title: const Text('Polls I\'ve Voted On'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Loading polls...');
    }

    if (_error != null) {
      return BoldaskErrorWidget(
        message: _error!,
        onRetry: () => _loadPolls(refresh: true),
      );
    }

    if (_polls.isEmpty) {
      return EmptyState(
        icon: Icons.how_to_vote_outlined,
        title: 'No Votes Yet',
        message: 'You haven\'t voted on any polls yet. Explore polls and share your opinion!',
        actionLabel: 'Explore Polls',
        onAction: () => context.push('/polls'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadPolls(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _polls.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _polls.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final poll = _polls[index];
          return _VotedPollCard(
            poll: poll,
            onTap: () => context.push('/polls/${poll.id}/results'),
          );
        },
      ),
    );
  }
}

/// Custom poll card that shows "Voted" badge.
class _VotedPollCard extends StatelessWidget {
  final PollModel poll;
  final VoidCallback? onTap;

  const _VotedPollCard({
    required this.poll,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        PollCard(
          poll: poll,
          onTap: onTap,
        ),
        Positioned(
          top: 16,
          right: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  'Voted',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
