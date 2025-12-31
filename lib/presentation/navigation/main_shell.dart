/// Main App Shell
/// Wraps main app screens with bottom navigation.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/explore/explore_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/library/library_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/profile/profile_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/planner/enhanced_ai_planner_screen.dart';
import 'package:studnet_ai_buddy/presentation/navigation/bottom_nav_bar.dart';

/// Main shell with bottom navigation.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static void switchTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_MainShellState>()?.switchTo(index);
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Dashboard state management
  late final DashboardViewModel _dashboardViewModel;
  late final List<Widget> _screens;
  int _currentIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize DashboardViewModel once and keep it alive
    _dashboardViewModel = getIt<DashboardViewModel>();

    // Initial load
    _dashboardViewModel.loadDashboard();

    _screens = [
      DashboardScreen(viewModel: _dashboardViewModel),
      const LibraryScreen(),
      const EnhancedAIPlannerScreen(),
      const ExploreScreen(),
      const ProfileScreen(),
    ];
  }

  void switchTo(int index) {
    setState(() {
      _currentIndex = index;
    });
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _screens.length,
      child: Builder(
        builder: (context) {
          _tabController = DefaultTabController.of(context);
          return Scaffold(
            extendBody: true, // For curved nav bar
            appBar: AppBar(
              backgroundColor: const Color(0xFF1A1A2E),
              elevation: 0,
              title: const Text(
                'Study Buddy',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Text('🎓', style: TextStyle(fontSize: 24)),
                  onPressed: () => _showMascotDialog(context),
                ),
              ],
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: _screens,
            ),
            bottomNavigationBar: BottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                switchTo(index);
              },
            ),
          );
        },
      ),
    );
  }

  void _showMascotDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C), // Dark surface
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF6C63FF),
              width: 2,
            ), // Accent border
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "🎓 AI Mentor",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Hello! I'm here to help you study.\nWhat would you like to do?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              // Action Buttons
              _buildMascotAction(
                context,
                "Ask a Question",
                Icons.chat_bubble_outline_rounded,
                () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/ai-mentor');
                },
              ),
              const SizedBox(height: 12),
              _buildMascotAction(
                context,
                "Generate Flashcards",
                Icons.flash_on_rounded,
                () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/add-flashcards');
                },
              ),
              const SizedBox(height: 12),
              _buildMascotAction(
                context,
                "Update Study Plan",
                Icons.calendar_month_rounded,
                () {
                  Navigator.pop(context);
                  DefaultTabController.of(context).animateTo(2);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMascotAction(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D2D44),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
