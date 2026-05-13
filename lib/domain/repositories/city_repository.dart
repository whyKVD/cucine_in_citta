// lib/domain/repositories/city_repository.dart

import '../entities/city_suggestion.dart';
import '../entities/cuisine.dart';

abstract class CityRepository {
  Future<List<CitySuggestion>> autocomplete(String term);
  Future<List<Cuisine>> getCuisines(double lat, double lng);
}
