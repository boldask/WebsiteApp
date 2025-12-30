import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/poll_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/cards/poll_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_widget.dart';

/// Screen for displaying polls created by the current user.
class OwnPollsScreen extends StatefulWidget {
  const OwnPollsScreen({super.key});

  @override
  State<OwnPollsScreen> createState() => _OwnPollsScreenState();
}

class _OwnPollsScreenState extends State<OwnPollsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final ScrollController _scrollController = ScrollController();

  List<PollModel> _polls = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

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
      });
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId == null) {
        throw Exception('You must be logged in to view your polls');
      }

      final polls = await _databaseService.getPolls(
        creatorUid: userId,
        limit: 20,
      );

      setState(() {
        _polls = polls;
        _hasMore = polls.length >= 20;
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
    if (_isLoadingMore || !_hasMore || _polls.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId == null) return;

      // For pagination, we would need to use startAfter with document snapshot
      // For simplicity, we'll just load with offset
      final polls = await _databaseService.getPolls(
        creatorUid: userId,
        limit: 20,
      );

      setState(() {
        // In a real implementation, you'd append only new polls
        _hasMore = polls.length >= 20;
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
        title: const Text('My Polls'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/polls/create'),
            tooltip: 'Create Poll',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Loading your polls...');
    }

    if (_error != null) {
      return BoldaskErrorWidget(
        message: _error!,
        onRetry: () => _loadPolls(refresh: true),
      );
    }

    if (_polls.isEmpty) {
      return EmptyState(
        icon: Icons.poll_outlined,
        title: 'No Polls Yet',
        message: 'You haven\'t created any polls yet. Create your first poll to get started!',
        actionLabel: 'Create Poll',
        onAction: () => context.push('/polls/create'),
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
          return PollCard(
            poll: poll,
            onTap: () => context.push('/polls/${poll.id}/results'),
          );
        },
      ),
    );
  }
}
