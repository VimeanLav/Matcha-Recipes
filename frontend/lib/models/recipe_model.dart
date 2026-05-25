enum RecipeCategory { drinks, desserts }

RecipeCategory recipeCategoryFromString(String value) {
  final normalized = value.trim().toLowerCase();
  return switch (normalized) {
    'drinks' => RecipeCategory.drinks,
    'desserts' => RecipeCategory.desserts,
    _ => RecipeCategory.drinks,
  };
}

String recipeCategoryToString(RecipeCategory category) {
  return switch (category) {
    RecipeCategory.drinks => 'Drinks',
    RecipeCategory.desserts => 'Desserts',
  };
}

class RecipeModel {
  RecipeModel({
    required this.id,
    required this.title,
    required this.category,
    required this.timeMinutes,
    required this.calories,
    required this.ingredients,
    required this.imageUrl,
    required this.createdBy,
    this.createdAt,
  });

  final String id;
  final String title;
  final RecipeCategory category;
  final int timeMinutes;
  final int calories;
  final String ingredients;
  final String imageUrl;
  final String createdBy;
  final DateTime? createdAt;

  factory RecipeModel.fromMap(Map<String, dynamic> data) {
    final createdAtRaw = data['created_at'] ?? data['createdAt'];
    DateTime? createdAt;
    if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw);
    }

    final timeRaw = data['time'] ?? data['time_minutes'] ?? data['timeMinutes'];
    final caloriesRaw = data['calories'];
    final imageRaw = data['image_url'] ?? data['imageUrl'];
    final createdByRaw = data['created_by'] ?? data['createdBy'];
    final idRaw = data['id'];

    return RecipeModel(
      id: idRaw == null ? '' : idRaw.toString(),
      title: (data['title'] as String? ?? '').trim(),
      category: recipeCategoryFromString(data['category'] as String? ?? ''),
      timeMinutes: _toInt(timeRaw),
      calories: _toInt(caloriesRaw),
      ingredients: (data['ingredients'] as String? ?? '').trim(),
      imageUrl: (imageRaw as String? ?? '').trim(),
      createdBy: (createdByRaw as String? ?? '').trim(),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'title': title,
      'category': recipeCategoryToString(category),
      'time': timeMinutes,
      'calories': calories,
      'ingredients': ingredients,
      'image_url': imageUrl,
      'created_by': createdBy,
    };
  }

  static int _toInt(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
