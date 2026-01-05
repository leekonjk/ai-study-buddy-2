import 'dart:io';

import 'package:flutter/foundation.dart'; // Added for debugPrint

import 'package:file_picker/file_picker.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:studnet_ai_buddy/domain/repositories/file_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/study_set_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/note_repository.dart';
import 'package:studnet_ai_buddy/domain/entities/study_set.dart';
import 'package:studnet_ai_buddy/domain/entities/note.dart';
import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LibraryViewModel extends BaseViewModel {
  final FileRepository _fileRepository;
  final StudySetRepository _studySetRepository;
  final NoteRepository _noteRepository;
  final FirebaseAuth _auth;

  LibraryViewModel({
    required FileRepository fileRepository,
    required StudySetRepository studySetRepository,
    required NoteRepository noteRepository,
    required FirebaseAuth auth,
  }) : _fileRepository = fileRepository,
       _studySetRepository = studySetRepository,
       _noteRepository = noteRepository,
       _auth = auth;

  // Search and Filter State
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _activeFilter = 'All';
  String get activeFilter => _activeFilter;

  // Files
  List<Map<String, dynamic>> _files = [];
  List<Map<String, dynamic>> get files => _files;

  // Upload Progress
  double? _uploadProgress;
  double? get uploadProgress => _uploadProgress;

  // ─────────────────────────────────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────────────────────
  // Filtered Getters
  // ─────────────────────────────────────────────────────────────────────────

  List<StudySet> filterStudySets(List<StudySet> sets) {
    if (_searchQuery.isEmpty) return sets;
    final query = _searchQuery.toLowerCase();
    return sets.where((set) {
      return set.title.toLowerCase().contains(query) ||
          set.category.toLowerCase().contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> get filteredFiles {
    return _files.where((file) {
      // 1. Filter by Search
      final name = (file['name'] ?? file['originalName'] ?? '')
          .toString()
          .toLowerCase();
      final matchesSearch =
          _searchQuery.isEmpty || name.contains(_searchQuery.toLowerCase());

      // 2. Filter by Category/Type
      bool matchesFilter = true;
      if (_activeFilter != 'All') {
        final type = (file['fileType'] ?? '').toString().toLowerCase();
        switch (_activeFilter) {
          case 'PDFs':
            matchesFilter = type == 'pdf';
            break;
          case 'Images':
            matchesFilter = ['jpg', 'jpeg', 'png', 'heic'].contains(type);
            break;
          case 'Docs':
            matchesFilter = ['doc', 'docx', 'txt'].contains(type);
            break;
        }
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Data Loading & Streams
  // ─────────────────────────────────────────────────────────────────────────

  Stream<Result<List<StudySet>>> watchStudySets() {
    return _studySetRepository.watchAllStudySets();
  }

  // Removed duplicate method declaration
  Stream<List<Note>> watchNotes() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _noteRepository.watchNotes(uid);
  }

  Future<void> loadFiles() async {
    setLoading(true);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        _files = [];
      } else {
        _files = await _fileRepository.getUserFiles(uid);
      }
      notifyListeners();
      setLoading(false);
    } catch (e) {
      setError("Failed to load files: $e");
      setLoading(false);
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }
  // Actions
  // ─────────────────────────────────────────────────────────────────────────
  // ... (existing code)

  Future<bool> uploadFile({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );

      // User cancelled the picker
      if (result == null) {
        return false;
      }

      // No file path available
      if (result.files.single.path == null) {
        setError("Could not access the selected file");
        return false;
      }

      setLoading(true);
      _uploadProgress = 0.0;
      notifyListeners();

      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        setError("User not logged in");
        setLoading(false);
        _uploadProgress = null;
        return false;
      }

      final file = File(result.files.single.path!);

      // Validate file exists
      if (!await file.exists()) {
        setError("Selected file does not exist");
        setLoading(false);
        _uploadProgress = null;
        return false;
      }

      String? textContent;
      // Extract text if PDF
      if (file.path.toLowerCase().endsWith('.pdf')) {
        try {
          // Update progress manually for extraction phase if needed, or just let user know
          // debugPrint('Extracting text...');
          textContent = await ReadPdfText.getPDFtext(file.path);
        } catch (e) {
          debugPrint('Error extracting PDF text: $e');
        }
      }

      final stream = _fileRepository.uploadFileWithProgress(
        file: file,
        userId: uid,
        originalName: result.files.single.name,
        textContent: textContent,
      );

      await for (final progress in stream) {
        _uploadProgress = progress;
        notifyListeners();
      }

      await loadFiles(); // Refresh list
      setLoading(false);
      _uploadProgress = null;
      notifyListeners();
      return true;
    } on FileFailure catch (e) {
      setError(e.message);
      setLoading(false);
      _uploadProgress = null;
      return false;
    } catch (e) {
      setError("Upload failed: ${e.toString()}");
      setLoading(false);
      _uploadProgress = null;
      return false;
    }
  }

  Future<void> deleteFile(String fileId, String storagePath) async {
    setLoading(true);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        setError("User not logged in");
        setLoading(false);
        return;
      }

      await _fileRepository.deleteFile(uid, fileId, storagePath);
      await loadFiles();
      setLoading(false);
    } on FileFailure catch (e) {
      setError(e.message);
      setLoading(false);
    } catch (e) {
      setError("Delete failed: ${e.toString()}");
      setLoading(false);
    }
  }
}
