/// Explore ViewModel
/// Manages state for the Explore screen, including search and filtering.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/study_set.dart';
import 'package:studnet_ai_buddy/domain/repositories/study_set_repository.dart';

class ExploreViewModel extends ChangeNotifier {
  final StudySetRepository _repository;

  ExploreViewModel(this._repository);

  // State
  bool _isLoading = false;
  String? _error;
  List<StudySet> _allSets = [];
  String _searchQuery = '';
  String? _selectedCategory;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  /// Get filtered study sets based on search query and selected category
  List<StudySet> get filteredSets {
    return _allSets.where((set) {
      // 1. Filter by Category
      if (_selectedCategory != null &&
          set.category.toLowerCase() != _selectedCategory!.toLowerCase()) {
        return false;
      }

      // 2. Filter by Search Query
      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      final title = set.title.toLowerCase();
      final category = set.category.toLowerCase();

      // Match title or category
      return title.contains(query) || category.contains(query);
    }).toList();
  }

  /// Load all public study sets
  Future<void> loadStudySets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getAllStudySets();
      if (result is Success<List<StudySet>>) {
        _allSets = result.value;
      } else if (result is Err) {
        _error = (result as Err).failure.message;
        _allSets = [];
      }
    } catch (e) {
      _error = 'Failed to load study sets: $e';
      _allSets = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Update selected category
  /// Tapping the same category again toggles it off
  void toggleCategory(String category) {
    if (_selectedCategory == category) {
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }
    notifyListeners();
  }
}
