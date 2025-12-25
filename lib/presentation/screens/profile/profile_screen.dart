/// Profile Screen
/// User profile and settings.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// User profile screen with settings and statistics.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: StudyBuddyColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 32),

                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: StudyBuddyColors.primary.withOpacity(0.1),
                  child: user?.photoURL != null
                      ? ClipOval(
                          child: Image.network(
                            user!.photoURL!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          size: 50,
                          color: StudyBuddyColors.primary,
                        ),
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  user?.displayName ?? 'Student',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // Email
                Text(
                  user?.email ?? 'Anonymous User',
                  style: const TextStyle(
                    fontSize: 16,
                    color: StudyBuddyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Stats
                Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Streak',
                      value: '7',
                      color: StudyBuddyColors.warning,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      icon: Icons.quiz_rounded,
                      label: 'Quizzes',
                      value: '24',
                      color: StudyBuddyColors.primary,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      icon: Icons.timer_rounded,
                      label: 'Hours',
                      value: '48',
                      color: StudyBuddyColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Settings section
                Container(
                  decoration: StudyBuddyDecorations.cardDecoration,
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profile',
                        onTap: () {},
                      ),
                      const Divider(
                        color: StudyBuddyColors.border,
                        height: 1,
                      ),
                      _buildSettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () {},
                      ),
                      const Divider(
                        color: StudyBuddyColors.border,
                        height: 1,
                      ),
                      _buildSettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        trailing: Switch(
                          value: true,
                          onChanged: (_) {},
                          activeColor: StudyBuddyColors.primary,
                        ),
                      ),
                      const Divider(
                        color: StudyBuddyColors.border,
                        height: 1,
                      ),
                      _buildSettingsTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sign out button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: StudyBuddyColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: StudyBuddyColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: StudyBuddyDecorations.borderRadiusFull,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: StudyBuddyDecorations.cardDecoration,
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: StudyBuddyColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: StudyBuddyColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: StudyBuddyColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(color: StudyBuddyColors.textPrimary),
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: StudyBuddyColors.textSecondary,
          ),
      onTap: onTap,
    );
  }
}

