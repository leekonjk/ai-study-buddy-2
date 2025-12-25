/// Statistics Screen
/// Display detailed study statistics and analytics.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// Statistics and analytics screen.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'Week';

  // Demo data
  final List<double> _weeklyStudyHours = [2.5, 3.0, 1.5, 4.0, 2.0, 3.5, 2.5];
  final List<String> _weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  double get _totalHours => _weeklyStudyHours.reduce((a, b) => a + b);
  double get _averageHours => _totalHours / _weeklyStudyHours.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: StudyBuddyColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period selector
                      _buildPeriodSelector().animate().fadeIn().slideY(
                        begin: 0.1,
                        end: 0,
                      ),
                      const SizedBox(height: 24),

                      // Overview cards
                      _buildOverviewCards()
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),

                      // Study hours chart
                      _buildStudyHoursChart()
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),

                      // Subject breakdown
                      _buildSubjectBreakdown()
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),

                      // Recent activity
                      _buildRecentActivity()
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideY(begin: 0.1, end: 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          IconButton(
            onPressed: () {
              // Share stats
            },
            icon: const Icon(
              Icons.share_rounded,
              color: StudyBuddyColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
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
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
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

  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer_rounded,
            label: 'Total Hours',
            value: '${_totalHours.toStringAsFixed(1)}h',
            color: StudyBuddyColors.primary,
            trend: '+15%',
            isUp: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.speed_rounded,
            label: 'Daily Avg',
            value: '${_averageHours.toStringAsFixed(1)}h',
            color: StudyBuddyColors.secondary,
            trend: '+8%',
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

  Widget _buildStudyHoursChart() {
    final maxHours = _weeklyStudyHours.reduce((a, b) => a > b ? a : b);

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
                'This $_selectedPeriod',
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
              children: List.generate(_weeklyStudyHours.length, (index) {
                final height = (_weeklyStudyHours[index] / maxHours) * 120;
                final isToday = index == DateTime.now().weekday - 1;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${_weeklyStudyHours[index].toStringAsFixed(1)}h',
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
                          height: height,
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
                          _weekDays[index],
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

  Widget _buildSubjectBreakdown() {
    final subjects = [
      {'name': 'Mathematics', 'hours': 5.5, 'color': Colors.blue},
      {'name': 'Biology', 'hours': 4.0, 'color': Colors.green},
      {'name': 'Physics', 'hours': 3.5, 'color': Colors.orange},
      {'name': 'Computer Science', 'hours': 3.0, 'color': Colors.purple},
      {'name': 'Chemistry', 'hours': 2.5, 'color': Colors.red},
    ];

    final totalHours = subjects.fold<double>(
      0,
      (sum, s) => sum + (s['hours'] as double),
    );

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
          ...subjects.map((subject) {
            final percentage = (subject['hours'] as double) / totalHours;
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
                          color: subject['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subject['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: StudyBuddyColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${(subject['hours'] as double).toStringAsFixed(1)}h',
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        subject['color'] as Color,
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

  Widget _buildRecentActivity() {
    final activities = [
      {
        'type': 'quiz',
        'title': 'Biology Quiz',
        'score': '92%',
        'time': '2h ago',
      },
      {
        'type': 'flashcard',
        'title': 'Math Flashcards',
        'score': '45 cards',
        'time': '4h ago',
      },
      {
        'type': 'focus',
        'title': 'Focus Session',
        'score': '1.5h',
        'time': 'Yesterday',
      },
      {
        'type': 'quiz',
        'title': 'Physics Quiz',
        'score': '88%',
        'time': 'Yesterday',
      },
    ];

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
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: StudyBuddyColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...activities.map(
            (activity) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getActivityColor(
                        activity['type']!,
                      ).withValues(alpha: 0.1),
                      borderRadius: StudyBuddyDecorations.borderRadiusS,
                    ),
                    child: Icon(
                      _getActivityIcon(activity['type']!),
                      size: 20,
                      color: _getActivityColor(activity['type']!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: StudyBuddyColors.textPrimary,
                          ),
                        ),
                        Text(
                          activity['time']!,
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
                      activity['score']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: StudyBuddyColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'quiz':
        return Icons.quiz_rounded;
      case 'flashcard':
        return Icons.style_rounded;
      case 'focus':
        return Icons.timer_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'quiz':
        return StudyBuddyColors.primary;
      case 'flashcard':
        return StudyBuddyColors.secondary;
      case 'focus':
        return StudyBuddyColors.warning;
      default:
        return StudyBuddyColors.success;
    }
  }
}
