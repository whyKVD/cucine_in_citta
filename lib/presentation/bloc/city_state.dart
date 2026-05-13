// lib/presentation/bloc/city_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/city_suggestion.dart';
import '../../domain/entities/cuisine.dart';

/// Top-level state discriminant
enum SearchPhase { idle, searching, suggestions, noResults, error }

enum CuisinePhase { loading, shown, empty, error }

/// The single state class for the whole screen
class CityState extends Equatable {
  // ── Search side ──────────────────────────────────────────────
  final String term;
  final SearchPhase searchPhase;
  final List<CitySuggestion> suggestions;

  // ── Cuisines side ────────────────────────────────────────────
  final CitySuggestion? selectedCity;
  final CuisinePhase? cuisinePhase; // null = no city selected yet
  final List<Cuisine> cuisines;

  final String? errorMessage;

  const CityState({
    this.term = '',
    this.searchPhase = SearchPhase.idle,
    this.suggestions = const [],
    this.selectedCity,
    this.cuisinePhase,
    this.cuisines = const [],
    this.errorMessage,
  });

  bool get showingCuisines => selectedCity != null;

  CityState copyWith({
    String? term,
    SearchPhase? searchPhase,
    List<CitySuggestion>? suggestions,
    CitySuggestion? selectedCity,
    bool clearSelectedCity = false,
    CuisinePhase? cuisinePhase,
    bool clearCuisinePhase = false,
    List<Cuisine>? cuisines,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CityState(
      term: term ?? this.term,
      searchPhase: searchPhase ?? this.searchPhase,
      suggestions: suggestions ?? this.suggestions,
      selectedCity:
          clearSelectedCity ? null : (selectedCity ?? this.selectedCity),
      cuisinePhase:
          clearCuisinePhase ? null : (cuisinePhase ?? this.cuisinePhase),
      cuisines: cuisines ?? this.cuisines,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        term,
        searchPhase,
        suggestions,
        selectedCity,
        cuisinePhase,
        cuisines,
        errorMessage,
      ];
}
