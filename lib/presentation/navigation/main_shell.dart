/// Main App Shell
/// Wraps main app screens with bottom navigation.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/navigation/bottom_nav_bar.dart';
import 'package:studnet_ai_buddy/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/explore/explore_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/library/library_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/profile/profile_screen.dart';

/// Main shell with bottom navigation.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const LibraryScreen(),
    const ExploreScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

