import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';
import 'package:studnet_ai_buddy/presentation/widgets/common/lottie_loading.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studnet_ai_buddy/presentation/widgets/cards/enhanced_stat_card.dart';
import 'package:studnet_ai_buddy/presentation/widgets/cards/minimal_tip_card.dart';
import 'package:studnet_ai_buddy/presentation/widgets/cards/circular_progress_card.dart';
import 'package:studnet_ai_buddy/presentation/navigation/app_router.dart';
import 'package:studnet_ai_buddy/presentation/navigation/main_shell.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DashboardViewModel>(
      create: (_) => getIt<DashboardViewModel>()..loadDashboard(),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardViewModel>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: LottieLoading(size: 120, message: 'Loading...'),
              )
            : RefreshIndicator(
                onRefresh: () => context.read<DashboardViewModel>().refresh(),
                color: AppColors.primary,
                child: CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: _Header(
                        greeting: state.greetingMessage,
                        name: state.greetingName,
                      ).animate().fadeIn(duration: 300.ms),
                    ),

                    // Error banner
                    if (state.hasError)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: _ErrorBanner(
                            message: state.errorMessage!,
                            onDismiss: () => context
                                .read<DashboardViewModel>()
                                .dismissError(),
                          ),
                        ),
                      ),

                    // Tip card
                    if (state.tipOfTheDay.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: MinimalTipCard(
                            tip: state.tipOfTheDay,
                          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                        ),
                      ),

                    // Visual Progress Section Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.xl,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Weekly Progress',
                              style: AppTypography.headline3,
                            ),
                            TextButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.statistics,
                              ),
                              icon: const Icon(Icons.trending_up, size: 16),
                              label: Text(
                                'Details',
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Stats Progerss Cards
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: _ProgressSection(
                          weeklyMinutes: state.weeklyStudyMinutes,
                          weeklyGoalMinutes: state.weeklyGoalMinutes,
                          completedTasks: state.completedTasksCount,
                          totalTasks: state.todayTasks.length,
                          streakDays: state.currentStreakDays,
                          dailyTaskGoal: state.dailyTaskGoal, // Added
                        ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                      ),
                    ),

                    // Focus for Today
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Focus for Today',
                              style: AppTypography.headline3,
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(
                                context,
                              ).pushNamed('/study-plan'),
                              child: Text(
                                'View All',
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Focus task
                    if (state.focusTask != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: _TaskCard(
                            task: state.focusTask!,
                          ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 48,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "No tasks for today!",
                                    style: AppTypography.body1.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Quick Actions
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.xl,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Text(
                          'Quick Actions',
                          style: AppTypography.headline3,
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: _QuickActionsGrid().animate().fadeIn(
                          delay: 400.ms,
                          duration: 300.ms,
                        ),
                      ),
                    ),

                    // Recent Activity
                    if (state.recentSessions.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.xl,
                            AppSpacing.md,
                            AppSpacing.sm,
                          ),
                          child: Text(
                            'Recent Activity',
                            style: AppTypography.headline3,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: _RecentActivityList(
                            sessions: state.recentSessions,
                          ).animate().fadeIn(delay: 500.ms, duration: 300.ms),
                        ),
                      ),
                    ],

                    // Bottom padding
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String greeting;
  final String name;

  const _Header({required this.greeting, required this.name});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final timeBasedGreeting = hour < 12
        ? '☀️ Good Morning'
        : hour < 17
        ? '🌤️ Good Afternoon'
        : '🌙 Good Evening';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.secondary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Row(
        children: [
          // Gradient Avatar
          Container(
            width: 60, // Slightly larger avatar
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeBasedGreeting,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name.isNotEmpty ? name : 'Student',
                  style: AppTypography.headline3.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24, // Larger name
                  ),
                ),
              ],
            ),
          ),
          // Notification bell with badge
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cardBackground,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              color: AppColors.textPrimary,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final int weeklyMinutes;
  final int weeklyGoalMinutes;
  final int completedTasks;
  final int totalTasks;
  final int streakDays;
  final int dailyTaskGoal; // Added

  const _ProgressSection({
    required this.weeklyMinutes,
    required this.weeklyGoalMinutes,
    required this.completedTasks,
    required this.totalTasks,
    required this.streakDays,
    required this.dailyTaskGoal,
  });

  @override
  Widget build(BuildContext context) {
    // Convert minutes to hours for display
    final hoursStudied = (weeklyMinutes / 60).floor();
    final goalHours = (weeklyGoalMinutes / 60).floor();

    return Row(
      children: [
        Expanded(
          child: CircularProgressCard(
            label: 'Study Hours',
            current: hoursStudied,
            target: goalHours,
            icon: Icons.access_time_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: CircularProgressCard(
            label: 'Tasks Today',
            current: completedTasks,
            target: totalTasks > 0
                ? totalTasks
                : dailyTaskGoal, // Use preference
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: EnhancedStatCard(
            icon: Icons.local_fire_department_rounded,
            value: '$streakDays',
            label: 'Streak',
            primaryColor: AppColors.warning,
            secondaryColor: Colors.deepOrange,
          ),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final dynamic task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.task_alt,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? 'Task',
                  style: AppTypography.subtitle1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Due Today',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate item width for 4 items per row accounting for spacing
        // (width - (spacing * 3)) / 4
        // Logic for grid:

        return GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.85, // Adjust for height
          children: [
            _ActionButton(
              icon: Icons.quiz_rounded,
              label: 'Quiz',
              color: AppColors.primary,
              onTap: () => Navigator.pushNamed(context, AppRoutes.quizSetup),
            ),
            _ActionButton(
              icon: Icons.psychology_rounded,
              label: 'AI Mentor',
              color: AppColors.secondary,
              onTap: () => Navigator.pushNamed(context, AppRoutes.aiMentor),
            ),
            _ActionButton(
              icon: Icons.timer_rounded,
              label: 'Focus',
              color: AppColors.accent,
              onTap: () => Navigator.pushNamed(context, AppRoutes.focusSession),
            ),
            _ActionButton(
              icon: Icons.auto_awesome_rounded,
              label: 'Plan',
              color: Colors.purple,
              onTap: () => MainShell.switchTab(context, 2),
            ),
            _ActionButton(
              icon: Icons.note_alt_rounded,
              label: 'Notes',
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, AppRoutes.notes),
            ),
            _ActionButton(
              icon: Icons.bar_chart_rounded,
              label: 'Stats',
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, AppRoutes.statistics),
            ),
            _ActionButton(
              icon: Icons.emoji_events_rounded,
              label: 'Badges',
              color: Colors.orange,
              onTap: () => Navigator.pushNamed(context, AppRoutes.achievements),
            ),
            _ActionButton(
              icon: Icons.settings_rounded, // New Settings shortcut
              label: 'Settings',
              color: Colors.grey,
              onTap: () async {
                await Navigator.pushNamed(context, AppRoutes.settings);
                // Refresh dashboard when returning from settings
                if (context.mounted) {
                  context.read<DashboardViewModel>().loadDashboard();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body2.copyWith(color: AppColors.error),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.error,
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  final List<dynamic> sessions;

  const _RecentActivityList({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: sessions.map((session) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (session.subjectId ?? '').isEmpty
                          ? 'Study Session'
                          : session.subjectId!,
                      style: AppTypography.subtitle1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _timeAgo(session.endTime ?? session.startTime),
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(session.actualDurationMinutes ?? 0)}m',
                style: AppTypography.subtitle2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
