import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/note.dart';

abstract class NoteRepository {
  Future<Result<List<Note>>> getNotes(String userId);
  Future<Result<Note?>> getNoteById(String id);
  Future<Result<Note>> createNote({
    required String title,
    required String content,
    required String subject,
    required String colorHex,
  });
  Future<Result<void>> updateNote(Note note);
  Future<Result<void>> deleteNote(String id);
  Stream<List<Note>> watchNotes(String userId);
}
