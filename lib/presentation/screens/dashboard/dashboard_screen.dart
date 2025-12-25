/// Dashboard Screen - Minimal Design.
/// Clean, minimal layout following design principles.
/// 8px grid system, purposeful spacing, minimal elements.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';
import 'package:studnet_ai_buddy/presentation/widgets/common/lottie_loading.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studnet_ai_buddy/presentation/widgets/cards/minimal_stat_card.dart';
import 'package:studnet_ai_buddy/presentation/widgets/cards/minimal_tip_card.dart';
import 'package:studnet_ai_buddy/presentation/navigation/app_router.dart';

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
            ? const LottieLoading(size: 120, message: 'Loading...')
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

                    // Stats
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: _StatsRow(
                          studyMinutes: state.totalStudyMinutes,
                          completedTasks: state.completedTasksCount,
                          streakDays: state.currentStreakDays,
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
                        child: _QuickActions().animate().fadeIn(
                          delay: 400.ms,
                          duration: 300.ms,
                        ),
                      ),
                    ),

                    // Bottom padding
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Minimal header.
class _Header extends StatelessWidget {
  final String greeting;
  final String name;

  const _Header({required this.greeting, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: AppTypography.body2),
                const SizedBox(height: 4),
                Text(
                  name.isNotEmpty ? name : 'Student',
                  style: AppTypography.headline3,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: AppColors.textPrimary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

/// Stats row - minimal.
class _StatsRow extends StatelessWidget {
  final int studyMinutes;
  final int completedTasks;
  final int streakDays;

  const _StatsRow({
    required this.studyMinutes,
    required this.completedTasks,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MinimalStatCard(
            icon: Icons.timer_outlined,
            value: '$studyMinutes',
            label: 'Study Time',
            unit: 'min',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: MinimalStatCard(
            icon: Icons.check_circle_outline,
            value: '$completedTasks',
            label: 'Completed',
            unit: 'tasks',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: MinimalStatCard(
            icon: Icons.local_fire_department_outlined,
            value: '$streakDays',
            label: 'Streak',
            unit: 'days',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

/// Minimal task card.
class _TaskCard extends StatelessWidget {
  final dynamic task; // StudyTask

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.task_alt,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title ?? 'Task', style: AppTypography.subtitle1),
                const SizedBox(height: 4),
                Text('Due today', style: AppTypography.body2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick actions - minimal.
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _ActionButton(
          icon: Icons.quiz,
          label: 'Quiz',
          color: AppColors.primary,
          onTap: () => Navigator.pushNamed(context, AppRoutes.quizSetup),
        ),
        _ActionButton(
          icon: Icons.psychology,
          label: 'AI Mentor',
          color: AppColors.secondary,
          onTap: () => Navigator.pushNamed(context, AppRoutes.aiMentor),
        ),
        _ActionButton(
          icon: Icons.timer,
          label: 'Focus',
          color: AppColors.accent,
          onTap: () => Navigator.pushNamed(context, AppRoutes.focusSession),
        ),
        _ActionButton(
          icon: Icons.auto_awesome,
          label: 'AI Plan',
          color: AppColors.highlight,
          onTap: () => Navigator.pushNamed(context, AppRoutes.aiPlanner),
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
      ],
    );
  }
}

/// Minimal action button.
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
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width:
            (MediaQuery.of(context).size.width -
                (AppSpacing.md * 2) -
                AppSpacing.sm) /
            2,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: AppTypography.body2),
          ],
        ),
      ),
    );
  }
}

/// Error banner - minimal.
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
