import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/entities/city_suggestion.dart';
import '../../domain/entities/cuisine.dart';
import '../../domain/repositories/city_repository.dart';
import '../models/city_suggestion_model.dart';
import '../models/cuisine_model.dart';

class BestieBiteRepository implements CityRepository {
  final http.Client _client;

  static const _baseUrl = 'api.bestiebite.com';
  static const _headers = {'User-Agent': 'BestieBite-Interview/1.0'};

  BestieBiteRepository({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<CitySuggestion>> autocomplete(String term) async {
    if (term.length < 2) return [];

    final uri = Uri.https(_baseUrl, '/places/v2/autocomplete', {
      'term': term,
      'lang': 'it',
      'limit': '8',
    });

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw HttpException(
        'Autocomplete failed with status ${response.statusCode}',
        response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];

    return CitySuggestionModel.fromJsonList(decoded)
        .map(_mapSuggestion)
        .toList();
  }

  @override
  Future<List<Cuisine>> getCuisines(double lat, double lng) async {
    final uri = Uri.https(
      _baseUrl,
      '/places/labels/by-location-and-type',
      {
        'lat': lat.toStringAsFixed(6),
        'lng': lng.toStringAsFixed(6),
        'type': 'cuisine',
      },
    );

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw HttpException(
        'Cuisines fetch failed with status ${response.statusCode}',
        response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final cuisinesResponse = CuisinesResponseModel.fromJson(decoded);
    return cuisinesResponse.data.map(_mapCuisine).toList();
  }

  CitySuggestion _mapSuggestion(CitySuggestionModel m) => CitySuggestion(
        id: m.id,
        name: m.name,
        latitude: m.latitude,
        longitude: m.longitude,
        mainText: m.mainText,
        secondaryText: m.secondaryText,
      );

  Cuisine _mapCuisine(CuisineModel m) => Cuisine(
        id: m.id,
        name: m.nameIt.isNotEmpty ? m.nameIt : m.name,
        imageUrl: m.imageEmoji,
        color: m.color,
        engLabel: m.engLabel,
      );
}

class HttpException implements Exception {
  final String message;
  final int statusCode;
  const HttpException(this.message, this.statusCode);

  @override
  String toString() => 'HttpException($statusCode): $message';
}
