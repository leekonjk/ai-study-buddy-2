/// Library Screen
/// Displays study sets, notes, and files with TabBar navigation.
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/presentation/navigation/app_router.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';

import 'package:studnet_ai_buddy/presentation/widgets/core/gradient_scaffold.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/library/library_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studnet_ai_buddy/presentation/widgets/cards/modern_file_card.dart';
import 'package:studnet_ai_buddy/domain/entities/study_set.dart';
import 'package:studnet_ai_buddy/domain/entities/note.dart';
import 'package:studnet_ai_buddy/presentation/widgets/cards/modern_note_card.dart';
import 'package:studnet_ai_buddy/presentation/widgets/common/loading_indicator.dart'; // Added import
import 'package:url_launcher/url_launcher.dart';

/// Library screen with tabs for Study Sets, Notes, and Files.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late LibraryViewModel _libraryViewModel;
  bool _isSearching = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _libraryViewModel = getIt<LibraryViewModel>();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Rebuild to update FAB
      }
    });
    // Load files when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _libraryViewModel.loadFiles();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return ChangeNotifierProvider.value(
      value: _libraryViewModel,
      child: GradientScaffold(
        body: Column(
          children: [
            // Header with Search
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ... existing header content
                  Row(
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
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _libraryViewModel.updateSearchQuery('');
                            }
                          });
                        },
                        icon: Icon(
                          _isSearching
                              ? Icons.close_rounded
                              : Icons.search_rounded,
                          color: StudyBuddyColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (_isSearching) ...[
                    const SizedBox(height: 16),
                    TextField(
                      autofocus: true,
                      style: const TextStyle(
                        color: StudyBuddyColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search study sets, files...',
                        hintStyle: const TextStyle(
                          color: StudyBuddyColors.textSecondary,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: StudyBuddyColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: StudyBuddyColors.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (value) {
                        _libraryViewModel.updateSearchQuery(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All'),
                          const SizedBox(width: 8),
                          _buildFilterChip('PDFs'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Images'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Docs'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Upload Progress
            Consumer<LibraryViewModel>(
              builder: (context, vm, child) {
                if (vm.uploadProgress == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Uploading...',
                            style: TextStyle(
                              color: StudyBuddyColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${(vm.uploadProgress! * 100).toInt()}%',
                            style: const TextStyle(
                              color: StudyBuddyColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: vm.uploadProgress,
                        backgroundColor: StudyBuddyColors.cardBackground,
                        color: StudyBuddyColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Tab bar

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
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.layers_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Sets'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_alt_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Notes'),
                      ],
                    ),
                  ),
                  Tab(
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
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _libraryViewModel.activeFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        _libraryViewModel.updateFilter(label);
      },
      backgroundColor: StudyBuddyColors.cardBackground,
      selectedColor: StudyBuddyColors.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected
            ? StudyBuddyColors.primary
            : StudyBuddyColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? StudyBuddyColors.primary
              : StudyBuddyColors.border,
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildStudySetsTab() {
    return StreamBuilder<Result<List<StudySet>>>(
      stream: _libraryViewModel.watchStudySets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading study sets: ${snapshot.error}'),
          );
        }

        final result = snapshot.data;
        if (result == null) return const SizedBox();

        return result.fold(
          onSuccess: (sets) {
            final filteredSets = _libraryViewModel.filterStudySets(sets);

            if (filteredSets.isEmpty) {
              if (_libraryViewModel.searchQuery.isNotEmpty) {
                return _buildEmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No matches found',
                  subtitle: 'Try adjusting your search query',
                );
              }
              return _buildEmptyState(
                icon: Icons.layers_outlined,
                title: 'No Study Sets Yet',
                subtitle: 'Create your first study set to get started!',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: filteredSets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final set = filteredSets[index];
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
                );
              },
            );
          },
          onFailure: (failure) =>
              Center(child: Text('Error: ${failure.message}')),
        );
      },
    );
  }

  Widget _buildNotesTab() {
    return StreamBuilder<List<Note>>(
      stream: _libraryViewModel.watchNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final notes = snapshot.data ?? [];

        // Filter notes based on search
        final query = _libraryViewModel.searchQuery.toLowerCase();
        final filteredNotes = notes.where((note) {
          return query.isEmpty ||
              note.title.toLowerCase().contains(query) ||
              note.content.toLowerCase().contains(query) ||
              note.subject.toLowerCase().contains(query);
        }).toList();

        if (filteredNotes.isEmpty) {
          if (query.isNotEmpty) {
            return _buildEmptyState(
              icon: Icons.search_off_rounded,
              title: 'No notes found',
              subtitle: 'Try adjusting your search query',
            );
          }
          return _buildEmptyState(
            icon: Icons.note_alt_outlined,
            title: 'No Notes Yet',
            subtitle: 'Create your first note to capture ideas!',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: filteredNotes.length,
          itemBuilder: (context, index) {
            final note = filteredNotes[index];
            return ModernNoteCard(
              note: note,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.noteEditor,
                  arguments: note,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFilesTab() {
    return Consumer<LibraryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: LoadingIndicator(message: 'Loading files...'),
          );
        }

        final files = viewModel.filteredFiles;

        if (files.isEmpty) {
          if (viewModel.searchQuery.isNotEmpty ||
              viewModel.activeFilter != 'All') {
            return _buildEmptyState(
              icon: Icons.search_off_rounded,
              title: 'No files found',
              subtitle: 'Try adjusting your search or filters',
            );
          }
          return _buildEmptyState(
            icon: Icons.folder_open_rounded,
            title: 'No Files Yet',
            subtitle: 'Upload PDFs, images, or docs to your library',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.6,
          ),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            // Fix: accessing 'name' instead of 'originalName' as per viewmodel fix
            final fileName =
                file['name'] ?? file['originalName'] ?? 'Unnamed File';
            final fileType = (file['fileType'] ?? 'unknown').toString();
            final fileSizeBytes = file['size'] ?? 0;
            final uploadedAt =
                (file['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            final thumbnailUrl = file['thumbnailUrl'];

            return ModernFileCard(
              fileName: fileName,
              fileType: fileType,
              fileSizeBytes: fileSizeBytes,
              uploadedAt: uploadedAt,
              thumbnailUrl: thumbnailUrl,
              onTap: null, // File opening disabled
              onDelete: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete File'),
                    content: Text('Are you sure you want to delete $fileName?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  viewModel.deleteFile(file['id'], file['storagePath']);
                }
              },
              onGenerateFlashcards: () {
                if (file['id'] != null) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.addFlashcards,
                    arguments: {
                      'studySetTitle': 'From $fileName',
                      'studySetCategory': 'General',
                      'fileId': file['id'],
                      'storagePath': file['storagePath'],
                      'autoStartAI': true,
                    },
                  );
                }
              },
            );
          },
        );
      },
    );
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
        break;
      default:
        fileType = FileType.any;
        break;
    }

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading...'),
            backgroundColor: StudyBuddyColors.primary,
          ),
        );

        // Use ViewModel directly since we have the instance
        final success = await _libraryViewModel.uploadFile(
          type: fileType,
          allowedExtensions: allowedExtensions,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Upload Successful!'),
                backgroundColor: StudyBuddyColors.success,
              ),
            );
          } else if (_libraryViewModel.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Upload failed: ${_libraryViewModel.errorMessage}',
                ),
                backgroundColor: StudyBuddyColors.error,
              ),
            );
          }
        }
      }
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
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        final index = _tabController.index;
        String label = 'Create';
        IconData icon = Icons.add_rounded;
        VoidCallback onTap = () {};

        switch (index) {
          case 0: // Sets
            label = 'Create Set';
            onTap = () =>
                Navigator.pushNamed(context, AppRoutes.createStudySet);
            break;
          case 1: // Notes
            label = 'Create Note';
            icon = Icons.edit_note_rounded;
            onTap = () => Navigator.pushNamed(context, AppRoutes.noteEditor);
            break;
          case 2: // Files
            label = 'Upload File';
            icon = Icons.upload_file_rounded;
            onTap = _showUploadSheet;
            break;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 100.0),
          child: FloatingActionButton.extended(
            onPressed: onTap,
            heroTag: 'library_fab_${_tabController.index}',
            backgroundColor: StudyBuddyColors.primary,
            icon: Icon(icon, color: Colors.white),
            label: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
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
