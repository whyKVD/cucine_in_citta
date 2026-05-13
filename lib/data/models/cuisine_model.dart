class CuisineModel {
  final int id;
  final String name;
  final String nameIt;
  final String nameEng;
  final String color;
  final String imageEmoji;
  final String engLabel;

  const CuisineModel({
    required this.id,
    required this.name,
    required this.nameIt,
    required this.nameEng,
    required this.color,
    required this.imageEmoji,
    required this.engLabel,
  });

  factory CuisineModel.fromJson(Map<String, dynamic> json) {
    return CuisineModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      nameIt: json['name_it'] as String? ?? json['name'] as String? ?? '',
      nameEng: json['name_eng'] as String? ?? '',
      color: json['color'] as String? ?? '#E84040',
      imageEmoji: json['image_emoji'] as String? ?? '',
      engLabel: json['eng_label'] as String? ?? '',
    );
  }

  static List<CuisineModel> fromJsonList(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(CuisineModel.fromJson)
        .toList();
  }
}

class CuisinesResponseModel {
  final int length;
  final List<CuisineModel> data;

  const CuisinesResponseModel({required this.length, required this.data});

  factory CuisinesResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>? ?? [];
    return CuisinesResponseModel(
      length: json['length'] as int? ?? rawData.length,
      data: CuisineModel.fromJsonList(rawData),
    );
  }
}
