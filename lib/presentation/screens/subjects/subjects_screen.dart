/// Subjects Screen
/// Displays all subjects/courses for the user.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/presentation/navigation/app_router.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// Screen displaying all user subjects.
class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  late Future<List<Subject>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  void _loadSubjects() {
    _subjectsFuture = getIt<AcademicRepository>().getAllSubjects().then(
      (result) => result.fold(
        onSuccess: (subjects) => subjects,
        onFailure: (_) => <Subject>[],
      ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
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
                      'My Subjects',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: StudyBuddyColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Subjects list
              Expanded(
                child: FutureBuilder<List<Subject>>(
                  future: _subjectsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final subjects = snapshot.data ?? [];

                    if (subjects.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 64,
                              color: StudyBuddyColors.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No subjects yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: StudyBuddyColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add your first subject to get started',
                              style: TextStyle(
                                color: StudyBuddyColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        return _buildSubjectCard(subjects[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubjectDialog(),
        backgroundColor: StudyBuddyColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _showAddSubjectDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: StudyBuddyColors.cardBackground,
        title: const Text(
          'Add Subject',
          style: TextStyle(color: StudyBuddyColors.textPrimary),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: StudyBuddyColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Subject Name',
            labelStyle: TextStyle(color: StudyBuddyColors.textSecondary),
            filled: true,
            fillColor: StudyBuddyColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Subject "${nameController.text}" created!'),
                  backgroundColor: StudyBuddyColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: StudyBuddyColors.primary,
            ),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.subjectDetail,
            arguments: subject.id,
          );
        },
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: StudyBuddyDecorations.cardDecoration,
          child: Row(
            children: [
              // Subject icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: StudyBuddyColors.primary.withValues(alpha: 0.1),
                  borderRadius: StudyBuddyDecorations.borderRadiusM,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: StudyBuddyColors.primary,
                ),
              ),
              const SizedBox(width: 16),

              // Subject info
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
                    const SizedBox(height: 4),
                    Text(
                      subject.code,
                      style: const TextStyle(
                        fontSize: 14,
                        color: StudyBuddyColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.chevron_right_rounded,
                color: StudyBuddyColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
