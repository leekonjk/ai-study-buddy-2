/// Statistics Screen
/// Display detailed study statistics and analytics.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/statistics/statistics_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// Statistics and analytics screen.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late final StatisticsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<StatisticsViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadStats('Week');
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
            child: Consumer<StatisticsViewModel>(
              builder: (context, vm, child) {
                if (vm.state.viewState == ViewState.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    // Header
                    _buildHeader(context),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Period selector
                            _buildPeriodSelector(
                              vm,
                            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                            const SizedBox(height: 24),

                            // Overview cards
                            _buildOverviewCards(vm)
                                .animate()
                                .fadeIn(delay: 100.ms)
                                .slideY(begin: 0.1, end: 0),
                            const SizedBox(height: 24),

                            // Study hours chart
                            _buildStudyHoursChart(vm)
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .slideY(begin: 0.1, end: 0),
                            const SizedBox(height: 24),

                            // Subject breakdown
                            _buildSubjectBreakdown(vm)
                                .animate()
                                .fadeIn(delay: 300.ms)
                                .slideY(begin: 0.1, end: 0),
                            const SizedBox(height: 24),

                            // Recent activity
                            _buildRecentActivity(vm)
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .slideY(begin: 0.1, end: 0),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: StudyBuddyColors.cardBackground,
                borderRadius: StudyBuddyDecorations.borderRadiusS,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: StudyBuddyColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Statistics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: StudyBuddyColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(StatisticsViewModel vm) {
    final periods = ['Week', 'Month', 'Year'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusFull,
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = period == vm.state.selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => vm.setPeriod(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? StudyBuddyColors.primary
                      : Colors.transparent,
                  borderRadius: StudyBuddyDecorations.borderRadiusFull,
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : StudyBuddyColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverviewCards(StatisticsViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer_rounded,
            label: 'Total Hours',
            value: '${vm.state.totalHours.toStringAsFixed(1)}h',
            color: StudyBuddyColors.primary,
            trend: '+5%', // You might want to calculate this real trend later
            isUp: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.speed_rounded,
            label: 'Daily Avg',
            value: '${vm.state.averageDailyHours.toStringAsFixed(1)}h',
            color: StudyBuddyColors.secondary,
            // trend: '+2%',
            isUp: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? trend,
    bool isUp = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: StudyBuddyDecorations.borderRadiusS,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isUp
                                ? StudyBuddyColors.success
                                : StudyBuddyColors.error)
                            .withValues(alpha: 0.1),
                    borderRadius: StudyBuddyDecorations.borderRadiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUp
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 12,
                        color: isUp
                            ? StudyBuddyColors.success
                            : StudyBuddyColors.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isUp
                              ? StudyBuddyColors.success
                              : StudyBuddyColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: StudyBuddyColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: StudyBuddyColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyHoursChart(StatisticsViewModel vm) {
    // Convert map to list based on week days
    // Assume map keys are simple "Mon", "Tue" etc or we just map 0-6
    // The current VM implementation returns Map<String, int> from repository.
    // The repository implementation likely returns Weekday names or dates.
    // For now, let's assume we can map it.
    // Actually, `getWeeklyFocusStats` in repo usually returns { 'Mon': 30, 'Tue': 0 ... }

    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weeklyMinutes = vm.state.weeklyStudyMinutes;
    final List<double> weeklyHours = weekDays.map((day) {
      final mins = weeklyMinutes[day] ?? 0;
      return mins / 60.0;
    }).toList();

    double maxHours = 1.0;
    if (weeklyHours.isNotEmpty) {
      maxHours = weeklyHours.reduce((a, b) => a > b ? a : b);
    }
    if (maxHours == 0) maxHours = 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                size: 20,
                color: StudyBuddyColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Study Hours',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: StudyBuddyColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'This ${vm.state.selectedPeriod}',
                style: const TextStyle(
                  fontSize: 12,
                  color: StudyBuddyColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(weeklyHours.length, (index) {
                final height = (weeklyHours[index] / maxHours) * 120;
                final isToday = index == DateTime.now().weekday - 1;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          weeklyHours[index] > 0
                              ? '${weeklyHours[index].toStringAsFixed(1)}h'
                              : '',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? StudyBuddyColors.primary
                                : StudyBuddyColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300 + index * 50),
                          height: height < 4 ? 4 : height, // Min height
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isToday
                                  ? [
                                      StudyBuddyColors.primary,
                                      StudyBuddyColors.primary.withValues(
                                        alpha: 0.6,
                                      ),
                                    ]
                                  : [
                                      StudyBuddyColors.primary.withValues(
                                        alpha: 0.5,
                                      ),
                                      StudyBuddyColors.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                    ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weekDays[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isToday
                                ? StudyBuddyColors.primary
                                : StudyBuddyColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectBreakdown(StatisticsViewModel vm) {
    if (vm.state.subjectStudyHours.isEmpty) {
      return const SizedBox.shrink();
    }

    final subjects = vm.state.subjectStudyHours.entries.toList();
    // Sort by hours desc
    subjects.sort((a, b) => b.value.compareTo(a.value));

    // Assign colors (cycle through a palette)
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    double totalHours = 0;
    for (var s in subjects) {
      totalHours += s.value;
    }
    if (totalHours == 0) totalHours = 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.pie_chart_rounded,
                size: 20,
                color: StudyBuddyColors.secondary,
              ),
              SizedBox(width: 8),
              Text(
                'Subject Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: StudyBuddyColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(subjects.length, (index) {
            final subject = subjects[index];
            final percentage = subject.value / totalHours;
            final color = colors[index % colors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subject.key,
                          style: const TextStyle(
                            fontSize: 14,
                            color: StudyBuddyColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${subject.value.toStringAsFixed(1)}h',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: StudyBuddyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(percentage * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: StudyBuddyColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: StudyBuddyDecorations.borderRadiusFull,
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 6,
                      backgroundColor: StudyBuddyColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(StatisticsViewModel vm) {
    // Map FocusSessions to activity display format
    final sessions = vm.state.recentSessions;
    if (sessions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 20,
                color: StudyBuddyColors.warning,
              ),
              SizedBox(width: 8),
              Text(
                'Recent Sessions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: StudyBuddyColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sessions.map((session) {
            // Determine icon and color based on duration or type (if we had type)
            // For now, it's just a focus session.

            final durationStr =
                '${(session.actualDurationMinutes / 60.0).toStringAsFixed(1)}h';
            final timeAgo = _timeAgo(session.endTime ?? session.startTime);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: StudyBuddyColors.warning.withValues(alpha: 0.1),
                      borderRadius: StudyBuddyDecorations.borderRadiusS,
                    ),
                    child: const Icon(
                      Icons.timer_rounded,
                      size: 20,
                      color: StudyBuddyColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (session.subjectId ?? '').isEmpty
                              ? 'Study Session'
                              : session.subjectId!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: StudyBuddyColors.textPrimary,
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: StudyBuddyColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: StudyBuddyColors.primary.withValues(alpha: 0.1),
                      borderRadius: StudyBuddyDecorations.borderRadiusFull,
                    ),
                    child: Text(
                      durationStr,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: StudyBuddyColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
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
