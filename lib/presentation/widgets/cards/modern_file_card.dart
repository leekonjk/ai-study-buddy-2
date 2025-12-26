import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Modern file card widget with icon, metadata, and actions
class ModernFileCard extends StatelessWidget {
  final String fileName;
  final String fileType;
  final int fileSizeBytes;
  final DateTime uploadedAt;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String? thumbnailUrl;

  const ModernFileCard({
    super.key,
    required this.fileName,
    required this.fileType,
    required this.fileSizeBytes,
    required this.uploadedAt,
    required this.onTap,
    required this.onDelete,
    this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    final fileIcon = _getFileIcon(fileType);
    final fileColor = _getFileColor(fileType);
    final fileSize = _formatFileSize(fileSizeBytes);
    final uploadDate = DateFormat('MMM d, yyyy').format(uploadedAt);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              colors: [fileColor.withValues(alpha: 0.05), Colors.transparent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File Icon/Thumbnail
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: fileColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: thumbnailUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.network(
                          thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFileIcon(fileIcon, fileColor),
                        ),
                      )
                    : _buildFileIcon(fileIcon, fileColor),
              ),
              const SizedBox(height: 6),

              // File Name
              Text(
                fileName,
                style: AppTypography.subtitle1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // File Metadata
              Row(
                children: [
                  Icon(
                    Icons.insert_drive_file_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      fileSize,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ), // Fixed spacing instead of Spacer to avoid layout issues in small spaces
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      uploadDate,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Actions Row
              Row(
                children: [
                  // File Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: fileColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      fileType.toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        color: fileColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    iconSize: 20,
                    color: AppColors.error,
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon(IconData icon, Color color) {
    return Center(child: Icon(icon, size: 48, color: color));
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'txt':
        return Icons.text_snippet_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
      case 'txt':
        return Colors.blue;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
