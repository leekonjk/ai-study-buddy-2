/// Dashboard Screen.
/// Main screen showing academic status and daily tasks.
/// 
/// Layer: Presentation (UI)
/// Responsibility: Display aggregated dashboard data.
/// Binds to: DashboardViewModel
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/entities/study_task.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';

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
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => context.read<DashboardViewModel>().refresh(),
                child: CustomScrollView(
                  slivers: [
                    // Greeting header
                    SliverToBoxAdapter(
                      child: _GreetingHeader(
                        greetingMessage: state.greetingMessage,
                        name: state.greetingName,
                      ),
                    ),

                    // Error banner
                    if (state.hasError)
                      SliverToBoxAdapter(
                        child: _ErrorBanner(
                          message: state.errorMessage!,
                          onDismiss: () => context.read<DashboardViewModel>().dismissError(),
                        ),
                      ),

                    // Stats row
                    SliverToBoxAdapter(
                      child: _StatsRow(
                        studyMinutes: state.totalStudyMinutes,
                        completedTasks: state.completedTasksCount,
                        streakDays: state.currentStreakDays,
                      ),
                    ),

                    // Focus task card
                    if (state.focusTask != null)
                      SliverToBoxAdapter(
                        child: _FocusTaskCard(task: state.focusTask!),
                      ),

                    // Tip of the day
                    if (state.tipOfTheDay.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _TipCard(tip: state.tipOfTheDay),
                      ),

                    // Subject progress section
                    if (state.activeSubjects.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _SubjectProgressSection(
                          subjects: state.activeSubjects,
                        ),
                      ),

                    // Today's tasks section
                    SliverToBoxAdapter(
                      child: _TasksSectionHeader(
                        totalTasks: state.todayTasks.length,
                        completedTasks: state.completedTasks.length,
                      ),
                    ),

                    // Task list
                    state.todayTasks.isEmpty
                        ? const SliverToBoxAdapter(child: _EmptyTasksCard())
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final task = state.todayTasks[index];
                                return _TaskCard(
                                  task: task,
                                  onComplete: () => context
                                      .read<DashboardViewModel>()
                                      .completeTask(task.id),
                                  onSkip: () => context
                                      .read<DashboardViewModel>()
                                      .skipTask(task.id),
                                );
                              },
                              childCount: state.todayTasks.length,
                            ),
                          ),

                    // Bottom padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/focus'),
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String greetingMessage;
  final String name;

  const _GreetingHeader({
    required this.greetingMessage,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greetingMessage,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Let\'s make today productive!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red[700])),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onDismiss,
            color: Colors.red[700],
          ),
        ],
      ),
    );
  }
}

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.timer_outlined,
              value: '$studyMinutes',
              label: 'min today',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle_outline,
              value: '$completedTasks',
              label: 'completed',
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.local_fire_department_outlined,
              value: '$streakDays',
              label: 'day streak',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}

class _FocusTaskCard extends StatelessWidget {
  final StudyTask task;

  const _FocusTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'FOCUS NOW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${task.estimatedMinutes} min',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            task.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            task.description.isNotEmpty ? task.description : 'No description',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(
                '/focus',
                arguments: {'taskId': task.id, 'subjectId': task.subjectId},
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Start Focus Session'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String tip;

  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(color: Colors.amber[900]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectProgressSection extends StatelessWidget {
  final List<SubjectProgress> subjects;

  const _SubjectProgressSection({required this.subjects});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'Subject Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return _SubjectProgressCard(subject: subject);
            },
          ),
        ),
      ],
    );
  }
}

class _SubjectProgressCard extends StatelessWidget {
  final SubjectProgress subject;

  const _SubjectProgressCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject.subjectName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: subject.progress,
            backgroundColor: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '${subject.completedTasks}/${subject.totalTasks} tasks',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}

class _TasksSectionHeader extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;

  const _TasksSectionHeader({
    required this.totalTasks,
    required this.completedTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Today\'s Tasks',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            '$completedTasks/$totalTasks',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTasksCard extends StatelessWidget {
  const _EmptyTasksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No tasks for today',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Great job staying ahead!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final StudyTask task;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const _TaskCard({
    required this.task,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green[200]! : Colors.grey[200]!,
        ),
      ),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted ? Colors.green : Colors.grey[400],
          ),
          onPressed: isCompleted ? null : onComplete,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          '${task.estimatedMinutes} min • ${task.type.name}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: isCompleted
            ? null
            : PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'skip') onSkip();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'skip',
                    child: Text('Skip task'),
                  ),
                ],
              ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0:
            break; // Already on dashboard
          case 1:
            Navigator.of(context).pushNamed('/quiz');
            break;
          case 2:
            Navigator.of(context).pushNamed('/focus');
            break;
          case 3:
            Navigator.of(context).pushNamed('/mentor');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.quiz_outlined),
          activeIcon: Icon(Icons.quiz),
          label: 'Quiz',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timer_outlined),
          activeIcon: Icon(Icons.timer),
          label: 'Focus',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology_outlined),
          activeIcon: Icon(Icons.psychology),
          label: 'Mentor',
        ),
      ],
    );
  }
}
