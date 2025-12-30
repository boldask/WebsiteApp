import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../config/routes.dart';
import 'polls_tab.dart';
import 'circles_tab.dart';
import 'favorites_tab.dart';

/// Main home screen with TabBar for Polls, Circles, and Favorites.
class HomeScreen extends StatefulWidget {
  final int initialTabIndex;

  const HomeScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Home',
      bottomNavIndex: 0,
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateOptions,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Polls'),
                Tab(text: 'Circles'),
                Tab(text: 'Favorites'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                PollsTab(),
                CirclesTab(),
                FavoritesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateOptions() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create New',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.poll_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: const Text('Create Poll'),
                subtitle: const Text('Ask a question and get opinions'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(Routes.addPoll);
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.group_outlined,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                title: const Text('Create Circle'),
                subtitle: const Text('Start a discussion group'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(Routes.addCircle);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
