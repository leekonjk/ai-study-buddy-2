/// Main App Shell
/// Wraps main app screens with bottom navigation.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/navigation/bottom_nav_bar.dart';
import 'package:studnet_ai_buddy/presentation/widgets/ai/ai_mascot_widget.dart';
import 'package:studnet_ai_buddy/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/explore/explore_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/library/library_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/profile/profile_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/planner/enhanced_ai_planner_screen.dart'; // Added

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
  int _currentIndex = 0;
  Offset _mascotOffset = const Offset(
    20,
    100,
  ); // Bottom-left default (relative to bottom-left)

  void switchTo(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const LibraryScreen(),
    const EnhancedAIPlannerScreen(), // Added
    const ExploreScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Positioned(
            left: _mascotOffset.dx,
            bottom: _mascotOffset.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  // Invert dy because Positioned uses 'bottom'
                  _mascotOffset = Offset(
                    _mascotOffset.dx + details.delta.dx,
                    _mascotOffset.dy - details.delta.dy,
                  );
                });
              },
              child: AIMascotWidget(
                onTap: () {
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
                              color: const Color(
                                0xFF6C63FF,
                              ).withValues(alpha: 0.3),
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
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Action Buttons
                            _buildMascotAction(
                              context,
                              "Ask a Question",
                              Icons.chat_bubble_outline_rounded,
                              () {
                                Navigator.pop(context);
                                Navigator.pushNamed(
                                  context,
                                  '/ai-mentor',
                                ); // Or Chat route
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
                                MainShell.switchTab(context, 2); // Planner tab
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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
