import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';

/// Dialog for configuring a new focus session before starting.
class SessionSetupDialog extends StatefulWidget {
  final String? preselectedSubjectId;
  final String? preselectedTaskId;

  const SessionSetupDialog({
    super.key,
    this.preselectedSubjectId,
    this.preselectedTaskId,
  });

  @override
  State<SessionSetupDialog> createState() => _SessionSetupDialogState();
}

class _SessionSetupDialogState extends State<SessionSetupDialog> {
  int _selectedMinutes = 25; // Default Pomodoro
  String? _selectedSubjectId;
  List<Subject> _userSubjects = [];
  bool _loadingSubjects = true;

  final List<SessionPreset> _presets = [
    SessionPreset(name: '⚡ Quick', minutes: 15, emoji: '⚡'),
    SessionPreset(name: '🍅 Pomodoro', minutes: 25, emoji: '🍅'),
    SessionPreset(name: '📚 Deep Focus', minutes: 45, emoji: '📚'),
    SessionPreset(name: '🎯 Power Hour', minutes: 60, emoji: '🎯'),
  ];

  @override
  void initState() {
    super.initState();
    // Don't set _selectedSubjectId here - validate after subjects load
    _loadUserSubjects();
  }

  /// Loads user's enrolled subjects from repository
  Future<void> _loadUserSubjects() async {
    try {
      final academicRepo = getIt<AcademicRepository>();
      final result = await academicRepo.getEnrolledSubjects();

      result.fold(
        onSuccess: (subjects) {
          if (mounted) {
            setState(() {
              _userSubjects = subjects;
              _loadingSubjects = false;
              // Only set preselected subject if it exists in loaded list
              if (widget.preselectedSubjectId != null) {
                final exists = subjects.any(
                  (s) => s.id == widget.preselectedSubjectId,
                );
                if (exists) {
                  _selectedSubjectId = widget.preselectedSubjectId;
                }
              }
            });
          }
        },
        onFailure: (failure) {
          debugPrint('Failed to load subjects: ${failure.message}');
          if (mounted) {
            setState(() {
              _userSubjects = [];
              _loadingSubjects = false;
              _selectedSubjectId = null; // Clear on failure
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Error loading subjects: $e');
      if (mounted) {
        setState(() {
          _userSubjects = [];
          _loadingSubjects = false;
          _selectedSubjectId = null; // Clear on error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: StudyBuddyColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    StudyBuddyColors.primary.withValues(alpha: 0.1),
                    StudyBuddyColors.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: StudyBuddyColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.timer_rounded,
                      color: StudyBuddyColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Focus Session',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: StudyBuddyColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Choose your session duration',
                          style: TextStyle(
                            fontSize: 14,
                            color: StudyBuddyColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Presets
                  const Text(
                    'Quick Presets',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presets.map((preset) {
                      final isSelected = _selectedMinutes == preset.minutes;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMinutes = preset.minutes;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? StudyBuddyColors.primary
                                : StudyBuddyColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? StudyBuddyColors.primary
                                  : StudyBuddyColors.border,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                preset.emoji,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${preset.minutes} min',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : StudyBuddyColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Custom Duration
                  const Text(
                    'Custom Duration',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: StudyBuddyColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: StudyBuddyColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Minutes:',
                              style: TextStyle(
                                fontSize: 14,
                                color: StudyBuddyColors.textSecondary,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (_selectedMinutes > 5) {
                                      setState(() {
                                        _selectedMinutes -= 5;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: StudyBuddyColors.primary,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: StudyBuddyColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$_selectedMinutes',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: StudyBuddyColors.primary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (_selectedMinutes < 120) {
                                      setState(() {
                                        _selectedMinutes += 5;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: StudyBuddyColors.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Slider(
                          value: _selectedMinutes.toDouble(),
                          min: 5,
                          max: 120,
                          divisions: 23,
                          activeColor: StudyBuddyColors.primary,
                          inactiveColor: StudyBuddyColors.primary.withValues(
                            alpha: 0.2,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedMinutes = value.round();
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '5 min',
                              style: TextStyle(
                                fontSize: 12,
                                color: StudyBuddyColors.textTertiary,
                              ),
                            ),
                            Text(
                              '120 min',
                              style: TextStyle(
                                fontSize: 12,
                                color: StudyBuddyColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Subject Selection (Optional)
                  const Text(
                    'Subject (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: StudyBuddyColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: StudyBuddyColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: Builder(
                        builder: (context) {
                          // Compute valid value - must exist in items or be null
                          final validSubjectIds = _userSubjects.map((s) => s.id).toSet();
                          final validValue = (_selectedSubjectId != null && 
                                             validSubjectIds.contains(_selectedSubjectId))
                              ? _selectedSubjectId
                              : null;
                          
                          return DropdownButton<String?>(
                            value: validValue,
                            isExpanded: true,
                            hint: const Text('Select a subject'),
                            dropdownColor: StudyBuddyColors.cardBackground,
                            style: const TextStyle(
                              color: StudyBuddyColors.textPrimary,
                              fontSize: 14,
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('No subject'),
                              ),
                              // Only show subject items when loaded and available
                              if (!_loadingSubjects)
                                ..._userSubjects.map((subject) {
                                  return DropdownMenuItem<String>(
                                    value: subject.id,
                                    child: Text(subject.name),
                                  );
                                }),
                            ],
                            onChanged: _loadingSubjects
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedSubjectId = value;
                                    });
                                  },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'minutes': _selectedMinutes,
                          'subjectId': _selectedSubjectId,
                          'taskId': widget.preselectedTaskId,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StudyBuddyColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Start ($_selectedMinutes min)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }
}

/// Model for session presets
class SessionPreset {
  final String name;
  final int minutes;
  final String emoji;

  SessionPreset({
    required this.name,
    required this.minutes,
    required this.emoji,
  });
}
