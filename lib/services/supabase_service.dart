import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/recipe_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // fetch all categories
  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.from('categories').select();
    return (response as List).map((json) => CategoryModel.fromJson(json)).toList();
  }

  // fetch recipes with ingredients (relational sql join)
  Future<List<RecipeModel>> getRecipes({String? categoryId}) async {
    var query = _client.from('recipes').select('*, ingredients(*)');

    if (categoryId != null && categoryId.isNotEmpty) {
      query = _client.from('recipes').select('*, ingredients(*)').eq('category_id', categoryId);
    }

    final response = await query;
    return (response as List).map((json) => RecipeModel.fromJson(json)).toList();
  }

  // Search recipes directly in Supabase using PostgreSQL ILIKE
  Future<List<RecipeModel>> searchRecipesFromSupabase(String searchQuery) async {
    final response = await _client
        .from('recipes')
        .select('*, ingredients(*)')
        .ilike('title', '%$searchQuery%');

    return (response as List).map((json) => RecipeModel.fromJson(json)).toList();
  }
}