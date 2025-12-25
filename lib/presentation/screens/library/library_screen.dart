/// Library Screen
/// Displays study sets with filters matching StudySmarter design.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/gradient_scaffold.dart';
import 'package:studnet_ai_buddy/presentation/widgets/cards/study_set_card.dart';

/// Library screen displaying study sets.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedFilter = 'Last 7 days';
  final int _filterCount = 2; // Example count

  // Mock data - will be replaced with real repository data
  final List<StudySetData> _studySets = [
    const StudySetData(
      id: '1',
      title: 'Software Quality Engineering - Software Testing',
      category: 'Computer sciences',
      hasContent: false,
      isOwned: true,
      isPrivate: true,
    ),
    const StudySetData(
      id: '2',
      title: 'Computer sciences',
      category: 'Computer sciences',
      topicCount: 2,
      flashcardCount: 2,
      fileCount: 1,
      isOwned: true,
      isPrivate: true,
      isHighlighted: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Library',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // Filter dropdown
                InkWell(
                  onTap: _showFilterMenu,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: StudyBuddyColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedFilter,
                        style: const TextStyle(
                          fontSize: 14,
                          color: StudyBuddyColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: StudyBuddyColors.cardBackgroundElevated,
                          borderRadius: StudyBuddyDecorations.borderRadiusS,
                        ),
                        child: Text(
                          '$_filterCount',
                          style: const TextStyle(
                            fontSize: 12,
                            color: StudyBuddyColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Study sets list
          Expanded(
            child: _studySets.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _studySets.length,
                    itemBuilder: (context, index) {
                      return StudySetCard(
                        studySet: _studySets[index],
                        onTap: () {
                          // TODO: Navigate to study set detail
                        },
                        onAddContent: () {
                          // TODO: Show add content dialog
                        },
                        onMenu: () {
                          // TODO: Show menu
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildEmptyState() {
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
            'No study sets yet',
            style: TextStyle(
              fontSize: 18,
              color: StudyBuddyColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first study set to get started',
            style: TextStyle(
              fontSize: 14,
              color: StudyBuddyColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Stack(
      children: [
        FloatingActionButton(
          onPressed: () {
            // TODO: Show create study set dialog
          },
          backgroundColor: Colors.white,
          child: const Icon(
            Icons.add_rounded,
            color: Colors.black,
            size: 28,
          ),
        ),
        // Lock overlay
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: StudyBuddyColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_rounded,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: StudyBuddyColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Filter by',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: StudyBuddyColors.textPrimary,
                ),
              ),
            ),
            _buildFilterOption('Last 7 days'),
            _buildFilterOption('Last 30 days'),
            _buildFilterOption('All time'),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String option) {
    final isSelected = _selectedFilter == option;
    return ListTile(
      title: Text(
        option,
        style: TextStyle(
          color: isSelected
              ? StudyBuddyColors.primary
              : StudyBuddyColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_rounded,
              color: StudyBuddyColors.primary,
            )
          : null,
      onTap: () {
        setState(() {
          _selectedFilter = option;
        });
        Navigator.pop(context);
        // TODO: Apply filter and update count
      },
    );
  }
}

