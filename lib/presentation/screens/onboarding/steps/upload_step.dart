/// Upload Step
/// File upload step matching StudySmarter design.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/chat_bubble.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/mascot_widget.dart';

/// File upload step for study materials.
class UploadStep extends StatefulWidget {
  const UploadStep({super.key});

  @override
  State<UploadStep> createState() => _UploadStepState();
}

class _UploadStepState extends State<UploadStep> {
  final List<String> _uploadedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Mascot and message
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MascotWidget(
                expression: MascotExpression.speaking,
                size: MascotSize.medium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChatBubble(
                  text: "Upload any materials you have",
                  isUser: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "We'll extract and cluster the knowledge from your materials for you to learn",
              style: TextStyle(
                fontSize: 14,
                color: StudyBuddyColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          // Upload section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: StudyBuddyColors.cardBackground,
              borderRadius: StudyBuddyDecorations.borderRadiusL,
              border: Border.all(color: StudyBuddyColors.border),
            ),
            child: Column(
              children: [
                const Text(
                  "Upload files (PDF, PPT, DOC) here. If you don't have materials we will generate AI flashcards for your plan.",
                  style: TextStyle(
                    fontSize: 14,
                    color: StudyBuddyColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _handleUploadFiles,
                        icon: const Icon(
                          Icons.upload_rounded,
                          color: StudyBuddyColors.textPrimary,
                        ),
                        label: const Text(
                          'Upload files',
                          style: TextStyle(color: StudyBuddyColors.textPrimary),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: StudyBuddyColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: StudyBuddyDecorations.borderRadiusM,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _handleScanMaterial,
                        icon: const Icon(
                          Icons.camera_alt_rounded,
                          color: StudyBuddyColors.textPrimary,
                        ),
                        label: const Text(
                          'Scan material',
                          style: TextStyle(color: StudyBuddyColors.textPrimary),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: StudyBuddyColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: StudyBuddyDecorations.borderRadiusM,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "The more resources you supply, the more relevant the output. You can add more materials later and we'll adjust your plan accordingly",
              style: TextStyle(
                fontSize: 12,
                color: StudyBuddyColors.textTertiary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          // Uploaded files list
          if (_uploadedFiles.isNotEmpty) ...[
            Expanded(
              child: ListView.builder(
                itemCount: _uploadedFiles.length,
                itemBuilder: (context, index) {
                  return _buildFileCard(_uploadedFiles[index], index);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: StudyBuddyDecorations.borderRadiusFull,
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(String fileName, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: StudyBuddyColors.error.withOpacity(0.1),
              borderRadius: StudyBuddyDecorations.borderRadiusS,
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: StudyBuddyColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(
                fontSize: 14,
                color: StudyBuddyColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _uploadedFiles.removeAt(index);
              });
            },
            icon: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: StudyBuddyColors.textTertiary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUploadFiles() {
    // TODO: Implement file picker
    setState(() {
      _uploadedFiles.add('Software Quality Engineering - Google Docs.pdf');
    });
  }

  void _handleScanMaterial() {
    // TODO: Implement camera/scanner
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera scan coming soon'),
        backgroundColor: StudyBuddyColors.cardBackground,
      ),
    );
  }

  void _handleNext() {
    // TODO: Save uploaded files and navigate
  }
}

