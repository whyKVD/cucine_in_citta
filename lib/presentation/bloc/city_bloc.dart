import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/repositories/city_repository.dart';
import 'city_event.dart';
import 'city_state.dart';

class CityBloc extends Bloc<CityEvent, CityState> {
  final CityRepository _repository;

  CityBloc(this._repository) : super(const CityState()) {
    on<SearchTermChanged>(
      _onSearchTermChanged,
      // Debounce: wait 300 ms after last keystroke before calling the API
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 300))
          .switchMap(mapper),
    );
    on<CitySelected>(_onCitySelected);
    on<BackToSearch>(_onBackToSearch);
    on<RetryRequested>(_onRetryRequested);
  }

  Future<void> _onSearchTermChanged(
    SearchTermChanged event,
    Emitter<CityState> emit,
  ) async {
    final term = event.term.trim();

    if (term.isEmpty) {
      emit(state.copyWith(
        term: term,
        searchPhase: SearchPhase.idle,
        suggestions: [],
        clearError: true,
      ));
      return;
    }

    if (term.length < 2) {
      emit(state.copyWith(
        term: term,
        searchPhase: SearchPhase.idle,
        suggestions: [],
      ));
      return;
    }

    emit(state.copyWith(
      term: term,
      searchPhase: SearchPhase.searching,
      clearSelectedCity: true,
      clearCuisinePhase: true,
      cuisines: [],
      clearError: true,
    ));

    try {
      final suggestions = await _repository.autocomplete(term);
      if (suggestions.isEmpty) {
        emit(state.copyWith(
          searchPhase: SearchPhase.noResults,
          suggestions: [],
        ));
      } else {
        emit(state.copyWith(
          searchPhase: SearchPhase.suggestions,
          suggestions: suggestions,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        searchPhase: SearchPhase.error,
        errorMessage: _formatError(e),
      ));
    }
  }

  Future<void> _onCitySelected(
    CitySelected event,
    Emitter<CityState> emit,
  ) async {
    emit(state.copyWith(
      selectedCity: event.city,
      cuisinePhase: CuisinePhase.loading,
      cuisines: [],
      clearError: true,
    ));

    try {
      final cuisines = await _repository.getCuisines(
        event.city.latitude,
        event.city.longitude,
      );
      if (cuisines.isEmpty) {
        emit(state.copyWith(cuisinePhase: CuisinePhase.empty));
      } else {
        emit(state.copyWith(
          cuisinePhase: CuisinePhase.shown,
          cuisines: cuisines,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        cuisinePhase: CuisinePhase.error,
        errorMessage: _formatError(e),
      ));
    }
  }

  void _onBackToSearch(BackToSearch event, Emitter<CityState> emit) {
    emit(state.copyWith(
      clearSelectedCity: true,
      clearCuisinePhase: true,
      cuisines: [],
      clearError: true,
      searchPhase: state.suggestions.isNotEmpty
          ? SearchPhase.suggestions
          : SearchPhase.idle,
    ));
  }

  Future<void> _onRetryRequested(
    RetryRequested event,
    Emitter<CityState> emit,
  ) async {
    if (state.selectedCity != null) {
      // Retry loading cuisines
      add(CitySelected(state.selectedCity!));
    } else {
      // Retry autocomplete
      add(SearchTermChanged(state.term));
    }
  }

  String _formatError(Object e) {
    return 'Qualcosa è andato storto. Riprova.';
  }
}
