import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:cucine_in_citta/data/models/city_suggestion_model.dart';
import 'package:cucine_in_citta/data/models/cuisine_model.dart';
import 'package:cucine_in_citta/data/repositories/bestiebite_repository.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class MockHttpClient extends Mock implements http.Client {}

// ── Fixtures ─────────────────────────────────────────────────────────────────

const _autocompleteFixture = '''
[
  {
    "id": 8047,
    "name": "Milano",
    "description": "Milano, Lombardia, Italia",
    "latitude": 45.4612939,
    "longitude": 9.172356290785304,
    "country_code": "IT",
    "structured_formatting": {
      "main_text": "Milano",
      "secondary_text": "Lombardia, Italia"
    }
  }
]
''';

const _cuisinesFixture = '''
{
  "length": 2,
  "data": [
    {
      "id": 52,
      "name": "Cinese",
      "name_it": "Cinese",
      "name_eng": "Chinese",
      "name_es": "China",
      "color": "#5B50A1",
      "image_emoji": "https://example.com/cinese.png",
      "type": "cuisine",
      "eng_label": "chinese"
    },
    {
      "id": 10,
      "name": "Pizza",
      "name_it": "Pizza",
      "name_eng": "Pizza",
      "name_es": "Pizza",
      "color": "#E84040",
      "image_emoji": "https://example.com/pizza.png",
      "type": "cuisine",
      "eng_label": "pizza"
    }
  ]
}
''';

// ── DTO parsing tests ─────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  group('CitySuggestionModel.fromJson', () {
    test('parses all fields correctly', () {
      final json = jsonDecode(_autocompleteFixture) as List<dynamic>;
      final models = CitySuggestionModel.fromJsonList(json);

      expect(models.length, 1);
      final m = models.first;
      expect(m.id, 8047);
      expect(m.name, 'Milano');
      expect(m.mainText, 'Milano');
      expect(m.secondaryText, 'Lombardia, Italia');
      expect(m.latitude, closeTo(45.461, 0.001));
      expect(m.longitude, closeTo(9.172, 0.001));
      expect(m.countryCode, 'IT');
    });

    test('returns empty list for empty JSON array', () {
      expect(CitySuggestionModel.fromJsonList([]), isEmpty);
    });
  });

  group('CuisineModel.fromJson', () {
    test('parses response correctly', () {
      final json = jsonDecode(_cuisinesFixture) as Map<String, dynamic>;
      final response = CuisinesResponseModel.fromJson(json);

      expect(response.length, 2);
      expect(response.data.length, 2);
      final cinese = response.data.first;
      expect(cinese.id, 52);
      expect(cinese.nameIt, 'Cinese');
      expect(cinese.nameEng, 'Chinese');
      expect(cinese.engLabel, 'chinese');
      expect(cinese.imageEmoji, 'https://example.com/cinese.png');
    });
  });

  group('BestieBiteRepository.autocomplete', () {
    late MockHttpClient mockClient;
    late BestieBiteRepository repo;

    setUp(() {
      mockClient = MockHttpClient();
      repo = BestieBiteRepository(client: mockClient);
    });

    test('returns empty list when term is shorter than 2 chars', () async {
      final result = await repo.autocomplete('m');
      expect(result, isEmpty);
      verifyNever(() => mockClient.get(any(), headers: any(named: 'headers')));
    });

    test('returns empty list when term is empty', () async {
      final result = await repo.autocomplete('');
      expect(result, isEmpty);
    });

    test('maps HTTP response to CitySuggestion entities', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => http.Response(_autocompleteFixture, 200));

      final results = await repo.autocomplete('mila');

      expect(results.length, 1);
      expect(results.first.name, 'Milano');
      expect(results.first.mainText, 'Milano');
      expect(results.first.secondaryText, 'Lombardia, Italia');
    });

    test('throws HttpException on non-200 status', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Forbidden', 403));

      expect(
        () => repo.autocomplete('mila'),
        throwsA(isA<HttpException>()),
      );
    });
  });

  group('BestieBiteRepository.getCuisines', () {
    late MockHttpClient mockClient;
    late BestieBiteRepository repo;

    setUp(() {
      mockClient = MockHttpClient();
      repo = BestieBiteRepository(client: mockClient);
    });

    test('returns list of Cuisine entities', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(_cuisinesFixture, 200));

      final results = await repo.getCuisines(45.46, 9.17);

      expect(results.length, 2);
      expect(results.first.name, 'Cinese');
      expect(results.last.name, 'Pizza');
    });

    test('throws HttpException on non-200 status', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () => repo.getCuisines(45.46, 9.17),
        throwsA(isA<HttpException>()),
      );
    });
  });
}
