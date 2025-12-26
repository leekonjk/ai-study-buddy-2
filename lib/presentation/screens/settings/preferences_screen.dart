import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/services/local_storage_service.dart';
import 'package:studnet_ai_buddy/presentation/widgets/dialogs/subject_dialog.dart';

/// Preferences screen for managing subjects, study settings, and app preferences
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // Preference Keys
  static const String _keyFocusDuration = 'pref_focus_duration';
  static const String _keyWeeklyGoal = 'pref_weekly_goal';
  static const String _keyDailyTaskGoal = 'pref_daily_task_goal'; // Added
  static const String _keyStudyReminders = 'pref_study_reminders';
  static const String _keyAchievementUnlocks = 'pref_achievement_unlocks';

  // State Variables
  int _focusDuration = 25;
  int _weeklyGoal = 15;
  int _dailyTaskGoal = 5; // Added
  bool _studyReminders = true;
  bool _achievementUnlocks = true;
  List<Subject> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = getIt<LocalStorageService>();
    final duration = await prefs.getInt(_keyFocusDuration);
    final goal = await prefs.getInt(_keyWeeklyGoal);
    final taskGoal = await prefs.getInt(_keyDailyTaskGoal); // Added
    final reminders = await prefs.getBool(_keyStudyReminders);
    final achievements = await prefs.getBool(_keyAchievementUnlocks);

    if (mounted) {
      setState(() {
        _focusDuration = duration ?? 25;
        _weeklyGoal = goal ?? 15;
        _dailyTaskGoal = taskGoal ?? 5; // Added
        _studyReminders = reminders ?? true;
        _achievementUnlocks = achievements ?? true;
      });
    }
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = getIt<LocalStorageService>();
    if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);

    final academicRepo = getIt<AcademicRepository>();
    final result = await academicRepo.getEnrolledSubjects();

    result.fold(
      onSuccess: (subjects) {
        if (mounted) {
          setState(() {
            _subjects = subjects;
            _isLoading = false;
          });
        }
      },
      onFailure: (_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

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
                      'Preferences',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: StudyBuddyColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: StudyBuddyColors.primary,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Subjects Section
                            _buildSectionHeader(
                              'Your Subjects',
                              'Manage your enrolled courses',
                            ),
                            const SizedBox(height: 16),
                            _buildSubjectsSection(),
                            const SizedBox(height: 32),

                            // Study Preferences Section
                            _buildSectionHeader(
                              'Study Preferences',
                              'Customize your study experience',
                            ),
                            const SizedBox(height: 16),
                            _buildStudyPreferencesSection(),
                            const SizedBox(height: 32),

                            // Notifications Section
                            _buildSectionHeader(
                              'Notifications',
                              'Manage your alerts and reminders',
                            ),
                            const SizedBox(height: 16),
                            _buildNotificationsSection(),
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

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: StudyBuddyColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: StudyBuddyColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsSection() {
    return Container(
      decoration: StudyBuddyDecorations.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_subjects.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: StudyBuddyColors.textSecondary.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No subjects yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add subjects to organize your study materials',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: StudyBuddyColors.textTertiary,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._subjects.map((subject) => _buildSubjectTile(subject)),

          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addSubject,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Subject'),
              style: OutlinedButton.styleFrom(
                foregroundColor: StudyBuddyColors.primary,
                side: const BorderSide(color: StudyBuddyColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTile(Subject subject) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: StudyBuddyColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: StudyBuddyColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: StudyBuddyColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.book_rounded,
                color: StudyBuddyColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: StudyBuddyColors.textPrimary,
                    ),
                  ),
                  if (subject.code.isNotEmpty)
                    Text(
                      subject.code,
                      style: const TextStyle(
                        fontSize: 12,
                        color: StudyBuddyColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _deleteSubject(subject),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: StudyBuddyColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyPreferencesSection() {
    return Container(
      decoration: StudyBuddyDecorations.cardDecoration,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.timer_outlined,
              color: StudyBuddyColors.textSecondary,
            ),
            title: const Text(
              'Default Focus Duration',
              style: TextStyle(color: StudyBuddyColors.textPrimary),
            ),
            subtitle: Text('$_focusDuration minutes'),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: StudyBuddyColors.textSecondary,
            ),
            onTap: _showDurationPicker,
          ),
          const Divider(height: 1, color: StudyBuddyColors.border),
          ListTile(
            leading: const Icon(
              Icons.flag_outlined,
              color: StudyBuddyColors.textSecondary,
            ),
            title: const Text(
              'Weekly Study Goal',
              style: TextStyle(color: StudyBuddyColors.textPrimary),
            ),
            subtitle: Text('$_weeklyGoal hours per week'),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: StudyBuddyColors.textSecondary,
            ),
            onTap: _showGoalPicker,
          ),
          const Divider(height: 1, color: StudyBuddyColors.border),
          ListTile(
            leading: const Icon(
              Icons.task_alt_rounded,
              color: StudyBuddyColors.textSecondary,
            ),
            title: const Text(
              'Daily Task Goal',
              style: TextStyle(color: StudyBuddyColors.textPrimary),
            ),
            subtitle: Text('$_dailyTaskGoal tasks per day'),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: StudyBuddyColors.textSecondary,
            ),
            onTap: _showTaskGoalPicker,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      decoration: StudyBuddyDecorations.cardDecoration,
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(
              Icons.notifications_outlined,
              color: StudyBuddyColors.textSecondary,
            ),
            title: const Text(
              'Study Reminders',
              style: TextStyle(color: StudyBuddyColors.textPrimary),
            ),
            subtitle: const Text('Get notified to study regularly'),
            value: _studyReminders,
            onChanged: (value) {
              setState(() => _studyReminders = value);
              _savePreference(_keyStudyReminders, value);
            },
            activeTrackColor: StudyBuddyColors.primary,
            activeColor: Colors.white,
          ),
          const Divider(height: 1, color: StudyBuddyColors.border),
          SwitchListTile(
            secondary: const Icon(
              Icons.emoji_events_outlined,
              color: StudyBuddyColors.textSecondary,
            ),
            title: const Text(
              'Achievement Unlocks',
              style: TextStyle(color: StudyBuddyColors.textPrimary),
            ),
            subtitle: const Text('Show when you unlock achievements'),
            value: _achievementUnlocks,
            onChanged: (value) {
              setState(() => _achievementUnlocks = value);
              _savePreference(_keyAchievementUnlocks, value);
            },
            activeTrackColor: StudyBuddyColors.primary,
            activeColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Future<void> _showDurationPicker() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        int selected = _focusDuration;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: StudyBuddyColors.cardBackground,
              title: const Text(
                'Focus Duration',
                style: TextStyle(color: StudyBuddyColors.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$selected minutes',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: StudyBuddyColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: selected.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    activeColor: StudyBuddyColors.primary,
                    onChanged: (value) {
                      setState(() => selected = value.toInt());
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, selected),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _focusDuration = result);
      _savePreference(_keyFocusDuration, result);
    }
  }

  Future<void> _showGoalPicker() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        int selected = _weeklyGoal;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: StudyBuddyColors.cardBackground,
              title: const Text(
                'Weekly Goal',
                style: TextStyle(color: StudyBuddyColors.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$selected hours',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: StudyBuddyColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: selected.toDouble(),
                    min: 1,
                    max: 40,
                    divisions: 39,
                    activeColor: StudyBuddyColors.primary,
                    onChanged: (value) {
                      setState(() => selected = value.toInt());
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, selected),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _weeklyGoal = result);
      _savePreference(_keyWeeklyGoal, result);
    }
  }

  Future<void> _showTaskGoalPicker() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        int selected = _dailyTaskGoal;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: StudyBuddyColors.cardBackground,
              title: const Text(
                'Daily Task Goal',
                style: TextStyle(color: StudyBuddyColors.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$selected tasks',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: StudyBuddyColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: selected.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    activeColor: StudyBuddyColors.primary,
                    onChanged: (value) {
                      setState(() => selected = value.toInt());
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, selected),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _dailyTaskGoal = result);
      _savePreference(_keyDailyTaskGoal, result);
    }
  }

  Future<void> _addSubject() async {
    final newSubject = await showDialog<Subject>(
      context: context,
      builder: (context) => const SubjectDialog(),
    );

    if (newSubject != null) {
      // Optimistic Update
      setState(() {
        _subjects.add(newSubject);
      });

      // Save to repository
      final academicRepo = getIt<AcademicRepository>();
      final result = await academicRepo.saveSubjects(_subjects);

      if (mounted) {
        result.fold(
          onSuccess: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${newSubject.name}'),
                backgroundColor: StudyBuddyColors.success,
              ),
            );
          },
          onFailure: (error) {
            // Revert on failure
            setState(() {
              _subjects.remove(newSubject);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save: ${error.message}'),
                backgroundColor: StudyBuddyColors.error,
              ),
            );
          },
        );
      }
    }
  }

  Future<void> _deleteSubject(Subject subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: StudyBuddyColors.cardBackground,
        title: const Text(
          'Delete Subject?',
          style: TextStyle(color: StudyBuddyColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to remove "${subject.name}"? This won\'t delete your existing notes or study sets.',
          style: const TextStyle(color: StudyBuddyColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: StudyBuddyColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final oldList = List<Subject>.from(_subjects);

      // Optimistic Update
      setState(() {
        _subjects.remove(subject);
      });

      // Save to repository
      final academicRepo = getIt<AcademicRepository>();
      final result = await academicRepo.saveSubjects(_subjects);

      if (mounted) {
        result.fold(
          onSuccess: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${subject.name} removed'),
                backgroundColor: StudyBuddyColors.success,
              ),
            );
          },
          onFailure: (error) {
            // Revert on failure
            setState(() {
              _subjects = oldList;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete: ${error.message}'),
                backgroundColor: StudyBuddyColors.error,
              ),
            );
          },
        );
      }
    }
  }
}
