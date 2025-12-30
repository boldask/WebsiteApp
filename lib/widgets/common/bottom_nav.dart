import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes.dart';

/// Reusable bottom navigation bar for the app.
class BoldaskBottomNav extends StatelessWidget {
  final int currentIndex;

  const BoldaskBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.poll_outlined),
          activeIcon: Icon(Icons.poll),
          label: 'Polls',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Circles',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        context.go('${Routes.home}?tab=0');
        break;
      case 1:
        context.go('${Routes.home}?tab=1');
        break;
      case 2:
        context.go('${Routes.home}?tab=2');
        break;
      case 3:
        context.go(Routes.settings);
        break;
    }
  }
}
