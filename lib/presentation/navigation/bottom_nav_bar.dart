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
    return CurvedNavigationBar(
      index: currentIndex,
      height: 65.0,
      items: const <Widget>[
        _NavIcon(icon: Icons.home_rounded, label: 'Home'),
        _NavIcon(icon: Icons.menu_book_rounded, label: 'Library'),
        _NavIcon(icon: Icons.explore_rounded, label: 'Explore'),
        _NavIcon(icon: Icons.person_rounded, label: 'Profile'),
      ],
      color: AppColors.cardBackground,
      buttonBackgroundColor: AppColors.primary,
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      onTap: onTap,
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _NavIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 26, color: AppColors.textPrimary),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Floating action button variant for center navigation.
class CenterFAB extends StatelessWidget {
  final VoidCallback? onTap;

  const CenterFAB({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
