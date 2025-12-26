import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

import 'package:studnet_ai_buddy/presentation/viewmodels/focus/focus_session_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/screens/focus/session_setup_dialog.dart';

/// Focus session screen with timer and controls.
class FocusSessionScreen extends StatefulWidget {
  final String? taskId;
  final String? subjectId;

  const FocusSessionScreen({super.key, this.taskId, this.subjectId});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen> {
  late final FocusSessionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<FocusSessionViewModel>();

    // Show setup dialog instead of auto-starting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_viewModel.state.hasActiveSession) {
        _showSessionSetupDialog();
      }
    });
  }

  /// Shows the session setup dialog and starts session with user's choices
  Future<void> _showSessionSetupDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionSetupDialog(
        preselectedSubjectId: widget.subjectId,
        preselectedTaskId: widget.taskId,
      ),
    );

    if (result != null && mounted) {
      // Start session with user's configuration
      _viewModel.startSession(
        durationMinutes: result['minutes'] as int,
        taskId: result['taskId'] as String?,
        subjectId: result['subjectId'] as String?,
      );
    } else {
      // User cancelled - go back
      if (mounted) {
        Navigator.pop(context);
      }
    }
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
            child: Consumer<FocusSessionViewModel>(
              builder: (context, vm, child) {
                final state = vm.state;

                // Handle error
                if (state.hasError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage!),
                        backgroundColor: StudyBuddyColors.error,
                      ),
                    );
                    vm.dismissError();
                  });
                }

                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              // If running, ask to cancel/complete? For now just pop and let it run in background or cancel?
                              // Usually timer runs in background? The VM keeps running if not disposed?
                              // But VM is factory, so it might be disposed if not singleton.
                              // Actually VM is factory. So state is lost if we pop?
                              // In a real app we'd have a singleton service or keep VM alive.
                              // For this scope, let's warn user or cancel session.
                              _viewModel.cancelSession();
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: StudyBuddyColors.textPrimary,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Focus Session',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: StudyBuddyColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const Spacer(),

                      // Timer display
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Progress ring
                          SizedBox(
                            width: 250,
                            height: 250,
                            child: CircularProgressIndicator(
                              value: state.progress,
                              strokeWidth: 12,
                              backgroundColor: StudyBuddyColors.cardBackground,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                state.isRunning
                                    ? StudyBuddyColors.primary
                                    : StudyBuddyColors.textSecondary,
                              ),
                            ),
                          ),
                          // Timer text
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.formattedRemaining,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: StudyBuddyColors.textPrimary,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.isRunning
                                    ? 'Stay focused!'
                                    : (state.isPaused ? 'Paused' : 'Ready?'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: StudyBuddyColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Reset/Cancel button
                          IconButton(
                            onPressed: () => _viewModel.startSession(
                              durationMinutes: 25,
                              taskId: widget.taskId,
                              subjectId: widget.subjectId,
                            ), // Reset to 25
                            // Or better: vm.cancelSession() then start new?
                            // Let's make it "Cancel" if running
                            icon: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: StudyBuddyColors.cardBackground,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: StudyBuddyColors.border,
                                ),
                              ),
                              child: const Icon(
                                Icons
                                    .refresh_rounded, // Use refresh icon for "Restart"
                                color: StudyBuddyColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),

                          // Play/Pause button
                          GestureDetector(
                            onTap: () {
                              if (state.isRunning) {
                                vm.pauseSession();
                              } else if (state.isPaused) {
                                vm.resumeSession();
                              } else if (!state.hasActiveSession) {
                                vm.startSession(
                                  durationMinutes: 25,
                                  taskId: widget.taskId,
                                  subjectId: widget.subjectId,
                                );
                              }
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: StudyBuddyColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                state.isRunning
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),

                          // Complete button
                          IconButton(
                            onPressed: () {
                              _viewModel.completeSession();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Great job! Session saved.'),
                                  backgroundColor: StudyBuddyColors.success,
                                ),
                              );
                            },
                            icon: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: StudyBuddyColors.success.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: StudyBuddyColors.success.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: StudyBuddyColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Session info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: StudyBuddyDecorations.cardDecoration,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoItem(
                              icon: Icons.timer_rounded,
                              label: 'Duration',
                              value: '${state.plannedMinutes} min',
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: StudyBuddyColors.border,
                            ),
                            _buildInfoItem(
                              icon: Icons.local_fire_department_rounded,
                              label: 'Focus Score',
                              value:
                                  '${((1 - state.progress) * 100).round()}%', // Just a visual proxy for now
                            ),
                          ],
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

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: StudyBuddyColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: StudyBuddyColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: StudyBuddyColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
