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
                              icon: Icons.note_alt_rounded,
                              title: 'My Notes',
                              onTap: () =>
                                  Navigator.pushNamed(context, AppRoutes.notes),
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
