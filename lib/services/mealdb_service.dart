import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';
import '../models/ingredient_model.dart';

class SpoonacularService {
  // Free Public Meal API URL (No API key restrictions & No CORS blocks)
  static const String _mealDbUrl = 'https://www.themealdb.com/api/json/v1/1/search.php?s=';

  Future<List<RecipeModel>> searchRecipesFromAPI(String query) async {
    try {
      final cleanQuery = query.trim().toLowerCase();
      if (cleanQuery.isEmpty) return [];

      // Smart Keyword Extractor for Asian/Local Search Queries
      String searchTerm = cleanQuery;
      if (cleanQuery.contains('zinger') || cleanQuery.contains('burger')) {
        searchTerm = 'burger';
      } else if (cleanQuery.contains('shuwarma') || cleanQuery.contains('shawarma')) {
        searchTerm = 'chicken';
      } else if (cleanQuery.contains('karhi') || cleanQuery.contains('curry')) {
        searchTerm = 'curry';
      } else if (cleanQuery.contains('chawal') || cleanQuery.contains('rice')) {
        searchTerm = 'rice';
      }

      final url = Uri.parse('$_mealDbUrl${Uri.encodeComponent(searchTerm)}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List? meals = data['meals'];

        if (meals == null || meals.isEmpty) return [];

        return meals.map((item) {
          // Parse dynamic ingredients
          List<IngredientModel> ingredientsList = [];
          for (int i = 1; i <= 20; i++) {
            final ingName = item['strIngredient$i'];
            final ingMeasure = item['strMeasure$i'];

            if (ingName != null && ingName.toString().trim().isNotEmpty) {
              ingredientsList.add(
                IngredientModel(
                  id: 'ing_$i',
                  name: ingName.toString().trim(),
                  baseQuantity: 1.0,
                  unit: ingMeasure?.toString().trim() ?? 'to taste',
                ),
              );
            }
          }

          return RecipeModel(
            id: 'meal_${item['idMeal']}',
            title: item['strMeal'] ?? 'Global Dish',
            description: 'Category: ${item['strCategory'] ?? "General"} | Region: ${item['strArea'] ?? "International"}',
            categoryId: 'api_category',
            imageUrl: item['strMealThumb'] ?? 'https://via.placeholder.com/300',
            cookingTimeMinutes: 25,
            calories: 380.0,
            proteinGrams: 24.0,
            carbsGrams: 42.0,
            fatsGrams: 14.0,
            youtubeVideoUrl: item['strYoutube'],
            instructions: item['strInstructions'] ?? 'Step 1: Follow standard preparation steps.',
            ingredients: ingredientsList,
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}