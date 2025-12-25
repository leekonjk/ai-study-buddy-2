/// Calendar Screen
/// Displays study schedule in calendar format.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// Calendar view for study schedules.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: StudyBuddyColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Calendar',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: StudyBuddyColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Month navigation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month - 1,
                          );
                        });
                      },
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: StudyBuddyColors.textPrimary,
                      ),
                    ),
                    Text(
                      _getMonthName(_focusedMonth),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: StudyBuddyColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month + 1,
                          );
                        });
                      },
                      icon: const Icon(
                        Icons.chevron_right_rounded,
                        color: StudyBuddyColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Day names
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                      .map(
                        (day) => SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: StudyBuddyColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Calendar grid
              Container(
                padding: const EdgeInsets.all(16),
                child: _buildCalendarGrid(),
              ),

              const Divider(color: StudyBuddyColors.border),

              // Selected date events
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: StudyBuddyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildEventCard(
                              title: 'Calculus Study Session',
                              time: '10:00 AM',
                              color: StudyBuddyColors.primary,
                            ),
                            _buildEventCard(
                              title: 'Physics Quiz',
                              time: '2:00 PM',
                              color: StudyBuddyColors.warning,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    );
    final startingWeekday = firstDayOfMonth.weekday % 7;

    final days = <Widget>[];

    // Previous month days
    for (int i = 0; i < startingWeekday; i++) {
      days.add(const SizedBox(width: 40, height: 40));
    }

    // Current month days
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected = _isSameDay(date, _selectedDate);
      final isToday = _isSameDay(date, DateTime.now());

      days.add(
        InkWell(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? StudyBuddyColors.primary
                  : isToday
                  ? StudyBuddyColors.primary.withValues(alpha: 0.1)
                  : null,
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(color: StudyBuddyColors.primary)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected || isToday
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : StudyBuddyColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.spaceAround,
      children: days,
    );
  }

  Widget _buildEventCard({
    required String title,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StudyBuddyColors.cardBackground,
          borderRadius: StudyBuddyDecorations.borderRadiusL,
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: StudyBuddyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: StudyBuddyColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
