/// Explore Screen
/// Discovery screen for finding study sets and topics.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/navigation/app_router.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/gradient_scaffold.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart'; // Added
import 'package:studnet_ai_buddy/domain/entities/study_set.dart'; // Added
import 'package:studnet_ai_buddy/domain/repositories/study_set_repository.dart'; // Added

/// Explore screen for discovering study content.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: StudyBuddyColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showSearchDialog(context),
                    icon: const Icon(
                      Icons.search_rounded,
                      color: StudyBuddyColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: StudyBuddyColors.cardBackground,
                  borderRadius: StudyBuddyDecorations.borderRadiusFull,
                  border: Border.all(color: StudyBuddyColors.border),
                ),
                child: const TextField(
                  style: TextStyle(color: StudyBuddyColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search study sets, topics...',
                    hintStyle: TextStyle(color: StudyBuddyColors.textTertiary),
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.search_rounded,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Categories section
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: StudyBuddyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryGrid(),
                  const SizedBox(height: 32),
                  const Text(
                    'Popular Study Sets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: StudyBuddyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPopularSets(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      'Computer sciences',
      'Mathematics',
      'Physics',
      'Chemistry',
      'Biology',
      'History',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (ctx, index) {
        return _buildCategoryCard(ctx, categories[index]);
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: StudyBuddyColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              style: const TextStyle(color: StudyBuddyColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search study sets, notes, topics...',
                hintStyle: TextStyle(color: StudyBuddyColors.textTertiary),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: StudyBuddyColors.textSecondary,
                ),
                filled: true,
                fillColor: StudyBuddyColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (query) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Searching for "$query"...')),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.library,
          arguments: {'category': category},
        );
      },
      borderRadius: StudyBuddyDecorations.borderRadiusL,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: StudyBuddyDecorations.cardDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 32,
              color: StudyBuddyColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: StudyBuddyColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSets() {
    return FutureBuilder(
      future: getIt<StudySetRepository>().getAllStudySets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<StudySet> sets = [];
        if (snapshot.hasData) {
          snapshot.data!.fold(
            onSuccess: (list) => sets = list,
            onFailure: (_) => sets = [],
          );
        }

        if (sets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: StudyBuddyColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.explore_off_rounded,
                    size: 48,
                    color: StudyBuddyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No public study sets found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Be the first to share one!',
                  style: TextStyle(
                    fontSize: 14,
                    color: StudyBuddyColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sets.length,
          itemBuilder: (context, index) {
            final set = sets[index];
            return InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.studySetDetail,
                  arguments: {
                    'studySetId': set.id,
                    'title': set.title,
                    'category': set.category,
                  },
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: StudyBuddyDecorations.cardDecoration,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            set.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: StudyBuddyColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${set.flashcardCount} flashcards • ${set.category}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: StudyBuddyColors.textSecondary,
                            ),
                          ),
                        ],
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
          },
        );
      },
    );
  }
}
