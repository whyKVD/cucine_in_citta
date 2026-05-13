// lib/domain/entities/cuisine.dart

import 'package:equatable/equatable.dart';

class Cuisine extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final String color;
  final String engLabel;

  const Cuisine({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.color,
    required this.engLabel,
  });

  @override
  List<Object?> get props => [id, name, engLabel];
}
