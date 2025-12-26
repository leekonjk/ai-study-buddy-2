import 'dart:async';
import 'package:studnet_ai_buddy/domain/entities/note.dart';
import 'package:studnet_ai_buddy/domain/repositories/note_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';

class NotesState {
  final ViewState viewState;
  final List<Note> notes;
  final String? errorMessage;
  final String selectedFilter;

  const NotesState({
    this.viewState = ViewState.initial,
    this.notes = const [],
    this.errorMessage,
    this.selectedFilter = 'All',
  });

  NotesState copyWith({
    ViewState? viewState,
    List<Note>? notes,
    String? errorMessage,
    String? selectedFilter,
  }) {
    return NotesState(
      viewState: viewState ?? this.viewState,
      notes: notes ?? this.notes,
      errorMessage: errorMessage,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  List<Note> get filteredNotes {
    if (selectedFilter == 'All') return notes;
    return notes.where((n) => n.subject == selectedFilter).toList();
  }

  List<String> get subjects => notes.map((n) => n.subject).toSet().toList();
}

class NotesViewModel extends BaseViewModel {
  final NoteRepository _noteRepository;
  final FirebaseAuth _auth;

  StreamSubscription? _notesSubscription;

  NotesState _state = const NotesState();
  NotesState get state => _state;

  NotesViewModel({
    required NoteRepository noteRepository,
    required FirebaseAuth auth,
  }) : _noteRepository = noteRepository,
       _auth = auth;

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }

  /// Initialize and start listening to notes stream
  void loadNotes() {
    _state = _state.copyWith(viewState: ViewState.loading);
    notifyListeners();

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _state = _state.copyWith(
        viewState: ViewState.error,
        errorMessage: 'User not logged in',
      );
      notifyListeners();
      return;
    }

    // Cancel existing subscription if any
    _notesSubscription?.cancel();

    _notesSubscription = _noteRepository
        .watchNotes(userId)
        .listen(
          (notes) {
            _state = _state.copyWith(
              viewState: ViewState.loaded,
              notes: notes,
              errorMessage: null,
            );
            notifyListeners();
          },
          onError: (error) {
            _state = _state.copyWith(
              viewState: ViewState.error,
              errorMessage: error.toString(),
            );
            notifyListeners();
          },
        );
  }

  void setFilter(String filter) {
    _state = _state.copyWith(selectedFilter: filter);
    notifyListeners();
  }

  Future<void> createNote({
    required String title,
    required String content,
    required String subject,
    required String colorHex,
  }) async {
    // Optimistic update could go here, but we rely on stream for now

    final result = await _noteRepository.createNote(
      title: title,
      content: content,
      subject: subject,
      colorHex: colorHex,
    );

    result.fold(
      onSuccess: (_) {
        // Stream will update UI
      },
      onFailure: (failure) {
        _state = _state.copyWith(errorMessage: failure.message);
        notifyListeners();
      },
    );
  }

  Future<void> deleteNote(String id) async {
    final result = await _noteRepository.deleteNote(id);

    result.fold(
      onSuccess: (_) {},
      onFailure: (failure) {
        _state = _state.copyWith(errorMessage: failure.message);
        notifyListeners();
      },
    );
  }
}
