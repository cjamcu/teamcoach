import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(currentLocation),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        items:  [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.users),
            label: 'Roster',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.gamepad2),
            label: 'Juegos',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.chartBar),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/roster')) return 0;
    if (location.startsWith('/games')) return 1;
    if (location.startsWith('/stats')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/roster');
        break;
      case 1:
        context.go('/games');
        break;
      case 2:
        context.go('/stats');
        break;
    }
  }
} 