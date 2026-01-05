/// Enhanced AI Planner Screen
/// AI-powered study planning interface.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/widgets/common/loading_indicator.dart'; // Added import
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/planner/ai_planner_viewmodel.dart';
import 'package:studnet_ai_buddy/domain/entities/study_task.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

/// AI-enhanced study planner screen.
class EnhancedAIPlannerScreen extends StatefulWidget {
  const EnhancedAIPlannerScreen({super.key});

  @override
  State<EnhancedAIPlannerScreen> createState() =>
      _EnhancedAIPlannerScreenState();
}

class _EnhancedAIPlannerScreenState extends State<EnhancedAIPlannerScreen>
    with AutomaticKeepAliveClientMixin {
  late final AIPlannerViewModel _viewModel;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<AIPlannerViewModel>()..loadPlan();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return ChangeNotifierProvider<AIPlannerViewModel>.value(
      value: _viewModel,
      child: const _PlannerContent(),
    );
  }
}

class _PlannerContent extends StatefulWidget {
  const _PlannerContent();

  @override
  State<_PlannerContent> createState() => _PlannerContentState();
}

class _PlannerContentState extends State<_PlannerContent> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AIPlannerViewModel>();
    final state = viewModel.state;

    return Scaffold(
      backgroundColor: StudyBuddyColors.background,
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
                      'AI Study Planner',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: StudyBuddyColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        final viewModel = context.read<AIPlannerViewModel>();
                        // Show confirmation dialog
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: StudyBuddyColors.cardBackground,
                            title: const Text(
                              'Regenerate Plan?',
                              style: TextStyle(
                                color: StudyBuddyColors.textPrimary,
                              ),
                            ),
                            content: const Text(
                              'This will delete your current plan and generate a fresh one based on your profile.',
                              style: TextStyle(
                                color: StudyBuddyColors.textSecondary,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: StudyBuddyColors.primary,
                                ),
                                child: const Text(
                                  'Regenerate',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          viewModel.regeneratePlan();
                        }
                      },
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: StudyBuddyColors.primary,
                      ),
                      tooltip: 'Regenerate Plan',
                    ),
                  ],
                ),
              ),

              if (state.viewState == ViewState.loading)
                const Expanded(child: Center(child: LoadingIndicator()))
              else if (state.viewState == ViewState.error)
                Expanded(
                  child: Center(
                    child: Text(
                      'Error: ${state.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      // Calendar
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: StudyBuddyColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month',
                            CalendarFormat.twoWeeks: '2 Weeks',
                            CalendarFormat.week: 'Week',
                          },
                          selectedDayPredicate: (day) {
                            return isSameDay(state.selectedDate, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                            });
                            // Call ViewModel to update selected date tasks
                            viewModel.selectDate(selectedDay);
                          },
                          onFormatChanged: (format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                          calendarStyle: CalendarStyle(
                            defaultTextStyle: const TextStyle(
                              color: StudyBuddyColors.textPrimary,
                            ),
                            weekendTextStyle: const TextStyle(
                              color: StudyBuddyColors.textSecondary,
                            ),
                            outsideTextStyle: TextStyle(
                              color: StudyBuddyColors.textSecondary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: StudyBuddyColors.primary,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: StudyBuddyColors.primary.withValues(
                                alpha: 0.3,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          headerStyle: const HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: false,
                            titleTextStyle: TextStyle(
                              color: StudyBuddyColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            leftChevronIcon: Icon(
                              Icons.chevron_left,
                              color: StudyBuddyColors.textPrimary,
                            ),
                            rightChevronIcon: Icon(
                              Icons.chevron_right,
                              color: StudyBuddyColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Task List
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // AI Suggestion (Tiny)
                              if (state.aiRecommendation.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: StudyBuddyColors.secondary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: StudyBuddyColors.secondary
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome,
                                        color: StudyBuddyColors.secondary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          state.aiRecommendation,
                                          style: const TextStyle(
                                            color:
                                                StudyBuddyColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              Text(
                                "Tasks for ${DateFormat('MMM d').format(state.selectedDate)}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: StudyBuddyColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),

                              if (state.tasks.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.event_available_rounded,
                                          size: 48,
                                          color: StudyBuddyColors.textSecondary
                                              .withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          "No tasks for this day.",
                                          style: TextStyle(
                                            color:
                                                StudyBuddyColors.textSecondary,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => _showAddTaskSheet(
                                            context,
                                            viewModel,
                                          ),
                                          child: const Text('Add Task'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ...state.tasks.map(
                                  (task) => _buildTaskCard(task),
                                ),

                              const SizedBox(height: 80), // Fab space
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0), // Clear BottomNavBar
        child: FloatingActionButton.extended(
          onPressed: () => _showAddTaskSheet(context, viewModel),
          backgroundColor: StudyBuddyColors.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('Add Task', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, AIPlannerViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: StudyBuddyColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New Task',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: StudyBuddyColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildChoiceCard(
              icon: Icons.edit_note_rounded,
              title: 'Manual Entry',
              subtitle: 'Create a custom task with full details',
              color: StudyBuddyColors.primary,
              onTap: () {
                Navigator.pop(context); // Close choice sheet
                _showManualTaskForm(context, viewModel);
              },
            ),
            const SizedBox(height: 16),
            _buildChoiceCard(
              icon: Icons.auto_awesome_rounded,
              title: 'AI Suggestion',
              subtitle: 'Get a task tailored to your goals',
              color: StudyBuddyColors.secondary,
              onTap: () {
                Navigator.pop(context); // Close choice sheet
                _showAITaskForm(context, viewModel);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StudyBuddyColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: StudyBuddyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
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

  void _showManualTaskForm(BuildContext context, AIPlannerViewModel viewModel) {
    String title = '';
    String description = '';
    String? selectedSubjectId;
    int duration = 60;
    TaskPriority priority = TaskPriority.medium;
    TimeOfDay selectedTime = TimeOfDay.now();

    if (viewModel.state.subjects.isNotEmpty) {
      selectedSubjectId = viewModel.state.subjects.first.id;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: StudyBuddyColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Custom Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: StudyBuddyColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              TextField(
                style: const TextStyle(color: StudyBuddyColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  labelStyle: const TextStyle(
                    color: StudyBuddyColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: StudyBuddyColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) => title = val,
              ),
              const SizedBox(height: 16),

              // Subject & Priority Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: StudyBuddyColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              viewModel.state.subjects.any(
                                (s) => s.id == selectedSubjectId,
                              )
                              ? selectedSubjectId
                              : null,
                          isExpanded: true,
                          dropdownColor: StudyBuddyColors.cardBackground,
                          hint: const Text('Subject'),
                          items: viewModel.state.subjects.map((s) {
                            return DropdownMenuItem(
                              value: s.id,
                              child: Text(
                                s.name,
                                style: const TextStyle(
                                  color: StudyBuddyColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setSheetState(() => selectedSubjectId = val);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: StudyBuddyColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TaskPriority>(
                          value: priority,
                          isExpanded: true,
                          dropdownColor: StudyBuddyColors.cardBackground,
                          items: TaskPriority.values.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text(
                                p.name.toUpperCase(),
                                style: TextStyle(
                                  color: _getPriorityColor(p),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setSheetState(() => priority = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description/Topic
              TextField(
                style: const TextStyle(color: StudyBuddyColors.textPrimary),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Topic / Description (Optional)',
                  labelStyle: const TextStyle(
                    color: StudyBuddyColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: StudyBuddyColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) => description = val,
              ),
              const SizedBox(height: 16),

              // Time & Duration
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          setSheetState(() => selectedTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: StudyBuddyColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: StudyBuddyColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              selectedTime.format(context),
                              style: const TextStyle(
                                color: StudyBuddyColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duration: ${duration}m',
                          style: const TextStyle(
                            color: StudyBuddyColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Slider(
                          value: duration.toDouble(),
                          min: 15,
                          max: 180,
                          divisions: 11,
                          activeColor: StudyBuddyColors.primary,
                          onChanged: (val) =>
                              setSheetState(() => duration = val.toInt()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (title.isEmpty) return;

                    Navigator.pop(context);

                    // Calculate date with time
                    final selectedDate = viewModel.state.selectedDate;
                    final date = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    viewModel.addTask(
                      title: title,
                      subjectId: selectedSubjectId ?? 'general',
                      date: date,
                      durationMinutes: duration,
                      description: description,
                      priority: priority,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task added successfully!'),
                        backgroundColor: StudyBuddyColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StudyBuddyColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Task',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAITaskForm(BuildContext context, AIPlannerViewModel viewModel) {
    String? selectedSubjectId;
    String topic = '';
    int duration = 45;
    TimeOfDay selectedTime = TimeOfDay.now();

    if (viewModel.state.subjects.isNotEmpty) {
      selectedSubjectId = viewModel.state.subjects.first.id;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: StudyBuddyColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: StudyBuddyColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Suggestion',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: StudyBuddyColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'I can help you plan. What subject are you working on?',
                style: TextStyle(color: StudyBuddyColors.textSecondary),
              ),
              const SizedBox(height: 12),

              // Subject Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: StudyBuddyColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value:
                        viewModel.state.subjects.any(
                          (s) => s.id == selectedSubjectId,
                        )
                        ? selectedSubjectId
                        : null,
                    isExpanded: true,
                    dropdownColor: StudyBuddyColors.cardBackground,
                    hint: const Text(
                      'Select Subject',
                      style: TextStyle(color: StudyBuddyColors.textSecondary),
                    ),
                    items: viewModel.state.subjects.map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text(
                          s.name,
                          style: const TextStyle(
                            color: StudyBuddyColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setSheetState(() => selectedSubjectId = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Topic Input
              TextField(
                style: const TextStyle(color: StudyBuddyColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Specific Topic (Optional)',
                  labelStyle: const TextStyle(
                    color: StudyBuddyColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: StudyBuddyColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) => topic = val,
              ),
              const SizedBox(height: 16),

              // Date and Time Selection
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          setSheetState(() => selectedTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: StudyBuddyColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: StudyBuddyColors.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              selectedTime.format(context),
                              style: const TextStyle(
                                color: StudyBuddyColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: StudyBuddyColors.background.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: StudyBuddyColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat(
                              'MMM d',
                            ).format(viewModel.state.selectedDate),
                            style: const TextStyle(
                              color: StudyBuddyColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Duration Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Time',
                    style: TextStyle(color: StudyBuddyColors.textSecondary),
                  ),
                  Text(
                    '$duration min',
                    style: const TextStyle(
                      color: StudyBuddyColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Slider(
                value: duration.toDouble(),
                min: 15,
                max: 120,
                divisions: 7,
                activeColor: StudyBuddyColors.secondary,
                onChanged: (val) => setSheetState(() => duration = val.toInt()),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedSubjectId == null) return;

                    Navigator.pop(context);

                    // Calculate date with time
                    final selectedDate = viewModel.state.selectedDate;
                    final date = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    viewModel.suggestTask(
                      subjectId: selectedSubjectId!,
                      topic: topic.isNotEmpty ? topic : null,
                      durationMinutes: duration,
                      date: date,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Asking AI for a suggestion...'),
                        backgroundColor: StudyBuddyColors.secondary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StudyBuddyColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Generate Task',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
      case TaskPriority.high:
        return StudyBuddyColors.error;
      case TaskPriority.medium:
        return StudyBuddyColors.warning;
      case TaskPriority.low:
        return StudyBuddyColors.success;
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  Widget _buildTaskCard(StudyTask task) {
    Color color = StudyBuddyColors.primary;
    IconData icon = Icons.menu_book_rounded;

    // Use Subject Color if available
    final viewModel = context.read<AIPlannerViewModel>();
    final subject = viewModel.state.subjects.cast<Subject?>().firstWhere(
      (s) => s?.id == task.subjectId,
      orElse: () => null,
    );

    if (subject != null) {
      try {
        color = _hexToColor(subject.colorHex);
      } catch (_) {} // Fallback to primary
    }

    if (task.type == TaskType.quiz) {
      icon = Icons.quiz_rounded;
    } else if (task.priority == TaskPriority.high) {
      // Keep color for subject, but maybe add an indicator?
      // Or override if strictly high priority?
      // Let's stick to subject color as the primary theme,
      // but maybe use a red border or icon for high priority?
      // For now, let's let subject color take precedence for identity,
      // but if it's a quiz, maybe we keep the quiz icon.
    }

    final timeString = DateFormat('h:mm a').format(task.date);
    final end = task.date.add(Duration(minutes: task.estimatedMinutes));
    final timeRange = "$timeString - ${DateFormat('h:mm a').format(end)}";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Builder(
        builder: (context) => InkWell(
          onTap: () {
            context.read<AIPlannerViewModel>().toggleTaskCompletion(task.id);
          },
          borderRadius: StudyBuddyDecorations.borderRadiusL,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: StudyBuddyColors.cardBackground,
              borderRadius: StudyBuddyDecorations.borderRadiusL,
              border: Border.all(
                color: task.isCompleted
                    ? StudyBuddyColors.success.withValues(alpha: 0.3)
                    : color.withValues(alpha: 0.3), // Subject color border
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? StudyBuddyColors.success
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted
                          ? StudyBuddyColors.success
                          : StudyBuddyColors.border,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: StudyBuddyDecorations.borderRadiusS,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: task.isCompleted
                              ? StudyBuddyColors.textTertiary
                              : StudyBuddyColors.textPrimary,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (subject != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                subject.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            timeRange,
                            style: const TextStyle(
                              fontSize: 12,
                              color: StudyBuddyColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
