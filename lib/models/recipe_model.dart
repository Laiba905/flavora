import 'package:hive/hive.dart';
import 'ingredient_model.dart';

part 'recipe_model.g.dart';

@HiveType(typeId: 0)
class RecipeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String categoryId;

  @HiveField(4)
  final String imageUrl;

  @HiveField(5)
  final int cookingTimeMinutes;

  @HiveField(6)
  final double calories;

  @HiveField(7)
  final double proteinGrams;

  @HiveField(8)
  final double carbsGrams;

  @HiveField(9)
  final double fatsGrams;

  @HiveField(10)
  final String? youtubeVideoUrl;

  @HiveField(11)
  final String instructions;

  final List<IngredientModel> ingredients;

  RecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.imageUrl,
    required this.cookingTimeMinutes,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
    this.youtubeVideoUrl,
    required this.instructions,
    this.ingredients = const [],
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Recipe',
      description: json['description']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      cookingTimeMinutes: (json['prep_time_minutes'] as num?)?.toInt() ?? 0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      proteinGrams: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbsGrams: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fatsGrams: (json['fats'] as num?)?.toDouble() ?? 0.0,
      youtubeVideoUrl: json['youtube_video_id']?.toString(),
      instructions: json['instructions']?.toString() ?? 'Step 1: Prepare ingredients.\nStep 2: Cook and serve.',
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
          .map((item) => IngredientModel.fromJson(item as Map<String, dynamic>))
          .toList()
          : [],
    );
  }
}