/// Study Set Card
/// Card widget for displaying study sets matching StudySmarter design.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// Study set data model for card display.
class StudySetData {
  final String id;
  final String title;
  final String category;
  final int topicCount;
  final int flashcardCount;
  final int fileCount;
  final bool isOwned;
  final bool isPrivate;
  final bool isHighlighted;
  final bool hasContent;

  const StudySetData({
    required this.id,
    required this.title,
    required this.category,
    this.topicCount = 0,
    this.flashcardCount = 0,
    this.fileCount = 0,
    this.isOwned = true,
    this.isPrivate = false,
    this.isHighlighted = false,
    this.hasContent = true,
  });
}

/// Study set card widget matching StudySmarter design.
class StudySetCard extends StatelessWidget {
  final StudySetData studySet;
  final VoidCallback? onTap;
  final VoidCallback? onAddContent;
  final VoidCallback? onMenu;

  const StudySetCard({
    super.key,
    required this.studySet,
    this.onTap,
    this.onAddContent,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: StudyBuddyDecorations.borderRadiusL,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StudyBuddyColors.cardBackground,
          borderRadius: StudyBuddyDecorations.borderRadiusL,
          border: studySet.isHighlighted
              ? Border.all(
                  color: StudyBuddyColors.warning,
                  width: 2,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and actions row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studySet.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: StudyBuddyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        studySet.category,
                        style: const TextStyle(
                          fontSize: 14,
                          color: StudyBuddyColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action icons
                if (onAddContent != null)
                  IconButton(
                    onPressed: onAddContent,
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: StudyBuddyColors.cardBackgroundElevated,
                        borderRadius: StudyBuddyDecorations.borderRadiusS,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: StudyBuddyColors.textSecondary,
                      ),
                    ),
                  ),
                if (studySet.isPrivate)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 20,
                      color: StudyBuddyColors.textTertiary,
                    ),
                  ),
                if (onMenu != null)
                  IconButton(
                    onPressed: onMenu,
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Content info or empty state
            if (!studySet.hasContent)
              const Text(
                'No content yet',
                style: TextStyle(
                  fontSize: 14,
                  color: StudyBuddyColors.textSecondary,
                ),
              )
            else
              Row(
                children: [
                  if (studySet.topicCount > 0) ...[
                    _buildContentChip(
                      '${studySet.topicCount} Topics',
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (studySet.flashcardCount > 0) ...[
                    _buildContentChip(
                      '${studySet.flashcardCount} Flashcards',
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (studySet.fileCount > 0) ...[
                    _buildContentChip(
                      '${studySet.fileCount} File${studySet.fileCount > 1 ? 's' : ''}',
                    ),
                  ],
                ],
              ),
            const SizedBox(height: 8),
            // Ownership indicator
            if (studySet.isOwned)
              Row(
                children: [
                  const Icon(
                    Icons.person_rounded,
                    size: 14,
                    color: StudyBuddyColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'By you',
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
    );
  }

  Widget _buildContentChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackgroundElevated,
        borderRadius: StudyBuddyDecorations.borderRadiusS,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: StudyBuddyColors.textSecondary,
        ),
      ),
    );
  }
}

