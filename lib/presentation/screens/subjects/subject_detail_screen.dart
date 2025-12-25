/// Subject Detail Screen
/// Displays detailed information about a specific subject.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// Detailed view of a subject with topics and study materials.
class SubjectDetailScreen extends StatefulWidget {
  final String subjectId;

  const SubjectDetailScreen({
    super.key,
    required this.subjectId,
  });

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  Subject? _subject;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubject();
  }

  Future<void> _loadSubject() async {
    // Get all subjects and find the one with matching ID
    final result = await getIt<AcademicRepository>().getAllSubjects();
    result.fold(
      onSuccess: (subjects) {
        final subject = subjects.where((s) => s.id == widget.subjectId).firstOrNull;
        setState(() {
          _subject = subject;
          _isLoading = false;
        });
      },
      onFailure: (_) {
        setState(() {
          _isLoading = false;
        });
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _subject == null
                  ? _buildNotFound()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: StudyBuddyColors.textTertiary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Subject not found',
            style: TextStyle(
              fontSize: 18,
              color: StudyBuddyColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button and title
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: StudyBuddyColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _subject!.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: StudyBuddyColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _subject!.code,
                  style: const TextStyle(
                    fontSize: 16,
                    color: StudyBuddyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Stats row
                Row(
                  children: [
                    _buildStatChip(
                      icon: Icons.star_rounded,
                      label: '${_subject!.creditHours} Credits',
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      icon: Icons.topic_rounded,
                      label: '${_subject!.topicIds.length} Topics',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Topics section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Topics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                if (_subject!.topicIds.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: StudyBuddyDecorations.cardDecoration,
                    child: const Center(
                      child: Text(
                        'No topics added yet',
                        style: TextStyle(
                          color: StudyBuddyColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  ...List.generate(
                    _subject!.topicIds.length,
                    (index) => _buildTopicCard(
                      'Topic ${index + 1}',
                      _subject!.topicIds[index],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Actions section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Study Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.quiz_rounded,
                        label: 'Take Quiz',
                        color: StudyBuddyColors.primary,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.style_rounded,
                        label: 'Flashcards',
                        color: StudyBuddyColors.secondary,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusFull,
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: StudyBuddyColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: StudyBuddyColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(String title, String topicId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: StudyBuddyDecorations.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: StudyBuddyColors.primary.withOpacity(0.1),
                borderRadius: StudyBuddyDecorations.borderRadiusS,
              ),
              child: const Icon(
                Icons.topic_rounded,
                color: StudyBuddyColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: StudyBuddyColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: StudyBuddyColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: StudyBuddyDecorations.borderRadiusL,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: StudyBuddyDecorations.borderRadiusL,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

