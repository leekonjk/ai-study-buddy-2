/// Profile Screen
/// User profile and settings.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/navigation/app_router.dart';

/// User profile screen with settings and statistics.
import 'package:provider/provider.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/profile/profile_viewmodel.dart';
import 'package:studnet_ai_buddy/domain/entities/achievement.dart';

/// User profile screen with settings and statistics.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProfileViewModel>();
    // Defer loading to allow init to complete (though safe here usually)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: StudyBuddyColors.backgroundGradient,
          ),
          child: SafeArea(
            child: Consumer<ProfileViewModel>(
              builder: (context, vm, child) {
                if (vm.state.viewState == ViewState.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: StudyBuddyColors.accent,
                    ),
                  );
                }

                // Fallback if basic info not loaded yet (shouldn't happen with loaded state, but for safety)
                final state = vm.state;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
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
                        backgroundColor: StudyBuddyColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: state.photoUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  state.photoUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.person_rounded,
                                        size: 50,
                                        color: StudyBuddyColors.primary,
                                      ),
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
                        state.displayName.isNotEmpty
                            ? state.displayName
                            : 'Student',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: StudyBuddyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Email
                      Text(
                        state.email.isNotEmpty ? state.email : 'Anonymous User',
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
                            value: '${state.streakDays}',
                            color: StudyBuddyColors.warning,
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            icon: Icons.quiz_rounded,
                            label: 'Quizzes',
                            value: '${state.quizzesCompleted}',
                            color: StudyBuddyColors.primary,
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            icon: Icons.timer_rounded,
                            label: 'Hours',
                            value: '${state.totalStudyHours}',
                            color: StudyBuddyColors.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Achievements
                      _buildAchievementsSection(context, state.achievements),
                      const SizedBox(height: 32),

                      // Settings section
                      Container(
                        decoration: StudyBuddyDecorations.cardDecoration,
                        child: Column(
                          children: [
                            _buildSettingsTile(
                              icon: Icons.settings_outlined,
                              title: 'Edit Preferences',
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.editProfile,
                                );
                              },
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
                                activeThumbColor: StudyBuddyColors.primary,
                              ),
                            ),
                            const Divider(
                              color: StudyBuddyColors.border,
                              height: 1,
                            ),
                            _buildSettingsTile(
                              icon: Icons.bar_chart_rounded,
                              title: 'Statistics',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.statistics,
                              ),
                            ),
                            const Divider(
                              color: StudyBuddyColors.border,
                              height: 1,
                            ),
                            _buildSettingsTile(
                              icon: Icons.emoji_events_rounded,
                              title: 'Achievements',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.achievements,
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
                            side: const BorderSide(
                              color: StudyBuddyColors.error,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  StudyBuddyDecorations.borderRadiusFull,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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

  Widget _buildAchievementsSection(
    BuildContext context,
    List<Achievement> achievements,
  ) {
    // Only show unlocked or first 3 locked ones as teaser
    final displayList = achievements;
    // In real app, might want to show all but greyed out.
    // For now, let's show all horizontally.

    if (displayList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Badges',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: StudyBuddyColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full achievement list
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: displayList.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final achievement = displayList[index];
              return Tooltip(
                message: '${achievement.title}\n${achievement.description}',
                triggerMode: TooltipTriggerMode.tap,
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: achievement.isUnlocked
                        ? StudyBuddyColors.accent.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: achievement.isUnlocked
                          ? StudyBuddyColors.accent.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        achievement.isUnlocked
                            ? Icons.emoji_events_rounded
                            : Icons.lock_outline_rounded,
                        color: achievement.isUnlocked
                            ? StudyBuddyColors.accent
                            : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      // Mini Label (optional, maybe too crowded)
                      // Text(achievement.title, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
      trailing:
          trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: StudyBuddyColors.textSecondary,
          ),
      onTap: onTap,
    );
  }
}
