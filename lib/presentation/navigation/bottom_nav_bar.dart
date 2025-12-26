/// Bottom Navigation Bar - Curved Design
/// Using curved_navigation_bar package for modern curved nav bar.
library;

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';

/// Curved bottom navigation bar with modern design.
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: CurvedNavigationBar(
        index: currentIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home_rounded, size: 26, color: AppColors.textPrimary),
          Icon(Icons.menu_book_rounded, size: 26, color: AppColors.textPrimary),
          Icon(
            Icons.calendar_month_rounded,
            size: 26,
            color: AppColors.textPrimary,
          ),
          Icon(Icons.explore_rounded, size: 26, color: AppColors.textPrimary),
          Icon(Icons.person_rounded, size: 26, color: AppColors.textPrimary),
        ],
        // Color of the bar itself
        color: AppColors.cardBackground,
        // Circle button (floating) color
        buttonBackgroundColor: AppColors.primary,
        // Background BEHIND the curve.
        // If extendBody is false, this should match the SCAFFOLD background to look seamless.
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: onTap,
      ),
    );
  }
}
