// lib/domain/entities/city_suggestion.dart

import 'package:equatable/equatable.dart';

class CitySuggestion extends Equatable {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String mainText;
  final String secondaryText;

  const CitySuggestion({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.mainText,
    required this.secondaryText,
  });

  @override
  List<Object?> get props => [id, name, latitude, longitude];
}
