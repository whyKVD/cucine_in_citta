// lib/presentation/bloc/city_event.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/city_suggestion.dart';

abstract class CityEvent extends Equatable {
  const CityEvent();
  @override
  List<Object?> get props => [];
}

/// User typed in the search field
class SearchTermChanged extends CityEvent {
  final String term;
  const SearchTermChanged(this.term);
  @override
  List<Object?> get props => [term];
}

/// User tapped a suggestion
class CitySelected extends CityEvent {
  final CitySuggestion city;
  const CitySelected(this.city);
  @override
  List<Object?> get props => [city];
}

/// User pressed back from cuisines view
class BackToSearch extends CityEvent {
  const BackToSearch();
}

/// User pressed retry after an error
class RetryRequested extends CityEvent {
  const RetryRequested();
}
