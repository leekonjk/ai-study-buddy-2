/// Library Screen
/// Displays study sets, notes, and files with TabBar navigation.
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/repositories/study_set_repository.dart';
import 'package:studnet_ai_buddy/presentation/navigation/app_router.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/gradient_scaffold.dart';
import 'package:studnet_ai_buddy/domain/entities/resource.dart';
import 'package:studnet_ai_buddy/domain/repositories/resource_repository.dart';
import 'package:studnet_ai_buddy/domain/services/file_upload_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Library screen with tabs for Study Sets, Notes, and Files.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<StudySet> _studySets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStudySets();
  }

  Future<void> _loadStudySets() async {
    final result = await getIt<StudySetRepository>().getAllStudySets();
    result.fold(
      onSuccess: (sets) {
        setState(() {
          _studySets = sets;
          _isLoading = false;
        });
      },
      onFailure: (_) {
        setState(() {
          _studySets = [];
          _isLoading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                  const Expanded(
                    child: Text(
                      'Library',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: StudyBuddyColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search_rounded,
                      color: StudyBuddyColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: StudyBuddyColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: StudyBuddyColors.border),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: StudyBuddyColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: StudyBuddyColors.primary,
                unselectedLabelColor: StudyBuddyColors.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.all(4),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.layers_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text('Sets (${_studySets.length})'),
                      ],
                    ),
                  ),
                  const Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_alt_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Notes'),
                      ],
                    ),
                  ),
                  const Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Files'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Study Sets tab
                  _buildStudySetsTab(),

                  // Notes tab
                  _buildNotesTab(),

                  // Files tab
                  _buildFilesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildStudySetsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_studySets.isEmpty) {
      return _buildEmptyState(
        icon: Icons.layers_rounded,
        title: 'No study sets yet',
        subtitle: 'Create your first study set to get started',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStudySets,
      color: StudyBuddyColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _studySets.length,
        itemBuilder: (context, index) {
          final set = _studySets[index];
          return _StudySetCard(
            studySet: set,
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
          ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
        },
      ),
    );
  }

  Widget _buildNotesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: StudyBuddyColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.note_alt_rounded,
              size: 40,
              color: StudyBuddyColors.secondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Notes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: StudyBuddyColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quick notes will appear here',
            style: TextStyle(
              fontSize: 14,
              color: StudyBuddyColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notes),
            style: OutlinedButton.styleFrom(
              foregroundColor: StudyBuddyColors.secondary,
              side: const BorderSide(color: StudyBuddyColors.secondary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Go to Notes'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Files Tab Implementation
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFilesTab() {
    return FutureBuilder(
      future: getIt<ResourceRepository>().getResources(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final result = snapshot.data;
        List<Resource> files = [];

        if (result != null) {
          result.fold(
            onSuccess: (list) => files = list,
            onFailure: (_) => files = [],
          );
        }

        if (files.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: StudyBuddyColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.cloud_upload_rounded,
                    size: 40,
                    color: StudyBuddyColors.accent,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Upload Study Materials',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PDFs, documents, and images',
                  style: TextStyle(
                    fontSize: 14,
                    color: StudyBuddyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showUploadSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StudyBuddyColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Upload File'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return _buildFileCard(file);
                },
              ),
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                onPressed: _showUploadSheet,
                backgroundColor: StudyBuddyColors.accent,
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFileCard(Resource file) {
    IconData icon;
    Color color;

    switch (file.type) {
      case ResourceType.pdf:
        icon = Icons.picture_as_pdf_rounded;
        color = Colors.red;
        break;
      case ResourceType.image:
        icon = Icons.image_rounded;
        color = Colors.blue;
        break;
      case ResourceType.document:
        icon = Icons.description_rounded;
        color = Colors.blueAccent;
        break;
      default:
        icon = Icons.insert_drive_file_rounded;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: StudyBuddyColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatFileSize(file.sizeBytes),
                  style: const TextStyle(
                    fontSize: 12,
                    color: StudyBuddyColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.download_rounded,
              color: StudyBuddyColors.textSecondary,
            ),
            onPressed: () {
              // Implement download or open URL
              // launchUrl(Uri.parse(file.url)); // requires url_launcher
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Downloading...")));
            },
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showUploadSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: StudyBuddyColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload Study Material',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: StudyBuddyColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a file type to upload',
                style: TextStyle(
                  fontSize: 14,
                  color: StudyBuddyColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildUploadOption(
                icon: Icons.picture_as_pdf_rounded,
                title: 'PDF Document',
                subtitle: 'Upload lecture slides, notes, etc.',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _pickFile('pdf');
                },
              ),
              const SizedBox(height: 12),
              _buildUploadOption(
                icon: Icons.image_rounded,
                title: 'Image',
                subtitle: 'Upload diagrams, handwritten notes',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  _pickFile('image');
                },
              ),
              const SizedBox(height: 12),
              _buildUploadOption(
                icon: Icons.description_rounded,
                title: 'Document',
                subtitle: 'Word, text, and other files',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  _pickFile('doc');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: StudyBuddyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _pickFile(String type) async {
    // Configure file types based on selection
    FileType fileType;
    List<String>? allowedExtensions;

    switch (type) {
      case 'pdf':
        fileType = FileType.custom;
        allowedExtensions = ['pdf'];
        break;
      case 'image':
        fileType = FileType.image;
        break;
      case 'doc':
        fileType = FileType.custom;
        allowedExtensions = ['doc', 'docx', 'txt'];
      default:
        fileType = FileType.any;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions,
        allowMultiple: false, // Simplify to single file for now
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        final path = platformFile.path;
        final name = platformFile.name;

        if (path == null) return;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Uploading...'),
              backgroundColor: StudyBuddyColors.primary,
              duration: Duration(seconds: 10), // Long duration while uploading
            ),
          );
        }

        // Upload
        try {
          final uploadResult = await getIt<FileUploadService>().uploadFile(
            filePath: path,
            fileName: name,
            onProgress: (progress) {
              // Update progress if UI supports it
            },
          );

          // Save Metadata
          final resource = Resource(
            id: uploadResult.fileId,
            userId: FirebaseAuth.instance.currentUser?.uid ?? '',
            title: uploadResult.fileName,
            url: uploadResult.fileUrl,
            type: Resource.parseType(uploadResult.fileType),
            sizeBytes: uploadResult.fileSize,
            uploadedAt: uploadResult.uploadedAt,
          );

          final saveResult = await getIt<ResourceRepository>().saveResource(
            resource,
          );

          saveResult.fold(
            onSuccess: (_) {
              if (mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Upload Successful!'),
                    backgroundColor: StudyBuddyColors.success,
                  ),
                );
                setState(() {}); // Refresh list
              }
            },
            onFailure: (f) {
              if (mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to save metadata: ${f.message}'),
                    backgroundColor: StudyBuddyColors.error,
                  ),
                );
              }
            },
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload failed: $e'),
                backgroundColor: StudyBuddyColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: StudyBuddyColors.error,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: StudyBuddyColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 40, color: StudyBuddyColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: StudyBuddyColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: StudyBuddyColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(context, AppRoutes.createStudySet),
      backgroundColor: StudyBuddyColors.primary,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'Create Set',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Study set card for library.
class _StudySetCard extends StatelessWidget {
  final StudySet studySet;
  final VoidCallback onTap;

  const _StudySetCard({required this.studySet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: StudyBuddyColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: StudyBuddyColors.border),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        StudyBuddyColors.primary.withValues(alpha: 0.8),
                        StudyBuddyColors.secondary.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.layers_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Info
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStatChip(
                            Icons.style_rounded,
                            '${studySet.flashcardCount} cards',
                          ),
                          const SizedBox(width: 12),
                          _buildStatChip(
                            Icons.topic_rounded,
                            '${studySet.topicCount} topics',
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: StudyBuddyColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          studySet.category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: StudyBuddyColors.primary,
                          ),
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
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: StudyBuddyColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: StudyBuddyColors.textSecondary),
        ),
      ],
    );
  }
}
