/// Focus Session Screen.
/// Timer-based focus/study session interface.
/// 
/// Layer: Presentation (UI)
/// Responsibility: Display timer, session controls, distraction logging.
/// Binds to: FocusSessionViewModel
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// Focus session screen with timer and controls.
class FocusSessionScreen extends StatefulWidget {
  final String? taskId;
  final String? subjectId;

  const FocusSessionScreen({
    super.key,
    this.taskId,
    this.subjectId,
  });

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  bool _isRunning = false;
  int _elapsedSeconds = 0;
  final int _targetMinutes = 25; // Default Pomodoro duration

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(minutes: _targetMinutes),
    );

    _timerController.addListener(() {
      setState(() {
        _elapsedSeconds = (_timerController.value * _targetMinutes * 60).round();
      });
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _timerController.forward();
      } else {
        _timerController.stop();
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _timerController.reset();
      _isRunning = false;
      _elapsedSeconds = 0;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final remainingSeconds = (_targetMinutes * 60) - _elapsedSeconds;
    final progress = _elapsedSeconds / (_targetMinutes * 60);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: StudyBuddyColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
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
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: StudyBuddyColors.cardBackground,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isRunning
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
                          _formatTime(remainingSeconds),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: StudyBuddyColors.textPrimary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isRunning ? 'Stay focused!' : 'Ready to start?',
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
                    // Reset button
                    IconButton(
                      onPressed: _resetTimer,
                      icon: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: StudyBuddyColors.cardBackground,
                          shape: BoxShape.circle,
                          border: Border.all(color: StudyBuddyColors.border),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: StudyBuddyColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Play/Pause button
                    GestureDetector(
                      onTap: _toggleTimer,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: StudyBuddyColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isRunning
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
                        // TODO: Save session and navigate
                        Navigator.pop(context);
                      },
                      icon: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: StudyBuddyColors.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: StudyBuddyColors.success.withOpacity(0.3),
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
                        value: '$_targetMinutes min',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: StudyBuddyColors.border,
                      ),
                      _buildInfoItem(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Focus Score',
                        value: '${((1 - progress) * 100).round()}%',
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
