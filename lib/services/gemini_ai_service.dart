import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';
import '../models/ingredient_model.dart';

class GeminiAiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  Future<RecipeModel?> generateRecipeFromIngredients(
      List<String> ingredients,
      ) async {
    if (ingredients.isEmpty) {
      print('DEBUG: Ingredients list is empty.');
      return null;
    }

    try {
      // Model endpoint updated to gemini-3.8-flash
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent?key=$_apiKey',
      );

      final prompt = '''
You are a master chef AI. Create a creative recipe using these ingredients: ${ingredients.join(', ')}.

Return ONLY a raw valid JSON object with NO markdown syntax (do NOT use ```json or ```).

Format:
{
  "title": "Recipe Name",
  "description": "Short summary",
  "prep_time_minutes": 20,
  "calories": 400.0,
  "protein": 25.0,
  "carbs": 45.0,
  "fats": 12.0,
  "instructions": "Step 1: Prep ingredients.\\nStep 2: Cook well.",
  "ingredients": [
    {"name": "Ingredient 1", "base_amount": 2.0, "unit": "pcs"}
  ]
}
''';

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      print('DEBUG: Response Code = ${response.statusCode}');
      print('DEBUG: Response Body = ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String rawText = responseData['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

        if (rawText.isEmpty) return null;

        String cleanJson = rawText.trim();
        if (cleanJson.startsWith('```json')) {
          cleanJson = cleanJson.replaceAll('```json', '').replaceAll('```', '').trim();
        } else if (cleanJson.startsWith('```')) {
          cleanJson = cleanJson.replaceAll('```', '').trim();
        }

        final Map<String, dynamic> data = json.decode(cleanJson);

        List<IngredientModel> parsedIngredients = [];
        if (data['ingredients'] != null) {
          parsedIngredients = (data['ingredients'] as List).map((ing) {
            return IngredientModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: ing['name'] ?? 'Item',
              baseQuantity: (ing['base_amount'] as num?)?.toDouble() ?? 1.0,
              unit: ing['unit'] ?? 'pcs',
            );
          }).toList();
        }

        return RecipeModel(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          title: data['title'] ?? 'AI Recipe',
          description: data['description'] ?? 'Generated recipe.',
          categoryId: 'ai_pantry',
          imageUrl: '[https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=800](https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=800)',
          cookingTimeMinutes: data['prep_time_minutes'] ?? 20,
          calories: (data['calories'] as num?)?.toDouble() ?? 350.0,
          proteinGrams: (data['protein'] as num?)?.toDouble() ?? 20.0,
          carbsGrams: (data['carbs'] as num?)?.toDouble() ?? 40.0,
          fatsGrams: (data['fats'] as num?)?.toDouble() ?? 12.0,
          youtubeVideoUrl: null,
          instructions: data['instructions'] ?? 'Follow standard cooking rules.',
          ingredients: parsedIngredients,
        );
      } else {
        return null;
      }
    } catch (e) {
      print('DEBUG: Exception = $e');
      return null;
    }
  }
}