import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:studnet_ai_buddy/domain/repositories/file_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/study_set_repository.dart';
import 'package:studnet_ai_buddy/domain/entities/study_set.dart';
import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LibraryViewModel extends BaseViewModel {
  final FileRepository _fileRepository;
  final StudySetRepository _studySetRepository;
  final FirebaseAuth _auth;

  LibraryViewModel({
    required FileRepository fileRepository,
    required StudySetRepository studySetRepository,
    required FirebaseAuth auth,
  }) : _fileRepository = fileRepository,
       _studySetRepository = studySetRepository,
       _auth = auth;

  List<Map<String, dynamic>> _files = [];
  List<Map<String, dynamic>> get files => _files;

  Stream<Result<List<StudySet>>> watchStudySets() {
    return _studySetRepository.watchAllStudySets();
  }

  Future<void> loadFiles() async {
    setLoading(true);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        _files = await _fileRepository.getUserFiles(uid);
      }
      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

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

      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        setError("User not logged in");
        setLoading(false);
        return false;
      }

      final file = File(result.files.single.path!);

      // Validate file exists
      if (!await file.exists()) {
        setError("Selected file does not exist");
        setLoading(false);
        return false;
      }

      await _fileRepository.uploadFile(
        file: file,
        userId: uid,
        originalName: result.files.single.name,
      );

      await loadFiles(); // Refresh list
      setLoading(false);
      return true;
    } on FileFailure catch (e) {
      setError(e.message);
      setLoading(false);
      return false;
    } catch (e) {
      setError("Upload failed: ${e.toString()}");
      setLoading(false);
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
