import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/recipe_model.dart';
import '../services/supabase_service.dart';
import '../services/hive_service.dart';
import '../services/mealdb_service.dart';

class RecipeViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final HiveService _hiveService = HiveService();
  final SpoonacularService _spoonacularService = SpoonacularService();

  // State variables
  List<CategoryModel> _categories = [];
  List<RecipeModel> _recipes = [];
  List<RecipeModel> _favoritesRecipes = [];

  String? _selectedCategoryId;
  bool _isLoading = false;
  String? _errorMessage;

  // Servings scaler state (default 1 serving)
  int _currentServings = 1;

  // Getters
  List<CategoryModel> get categories => _categories;
  List<RecipeModel> get recipes => _recipes;
  List<RecipeModel> get favoriteRecipes => _favoritesRecipes;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentServings => _currentServings;

  // 1. Initial Data Fetch (Categories + Recipes + Favorites)
  Future<void> fetchInitialData() async {
    _setLoading(true);
    try {
      _categories = await _supabaseService.getCategories();
      _recipes = await _supabaseService.getRecipes();
      loadFavorites();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Problem in fetching data: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  // 2. Hybrid Search Logic (Supabase -> Spoonacular API Fallback)
  Future<void> searchRecipes(String query) async {
    if (query.trim().isEmpty) {
      fetchInitialData();
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      // Step A: Pehle Supabase Database mein search karein
      List<RecipeModel> supabaseResults =
      await _supabaseService.searchRecipesFromSupabase(query);

      if (supabaseResults.isNotEmpty) {
        _recipes = supabaseResults;
      } else {
        // Step B: Agar Supabase mein na mile, to Spoonacular API hit karein
        List<RecipeModel> apiResults =
        await _spoonacularService.searchRecipesFromAPI(query);
        _recipes = apiResults;
      }
    } catch (e) {
      _recipes = [];
      _errorMessage = "Search karne mein issue aaya.";
    } finally {
      _setLoading(false);
    }
  }

  // 3. Filter Recipes by Category
  Future<void> selectCategory(String? categoryId) async {
    if (_selectedCategoryId == categoryId) {
      _selectedCategoryId = null; // Toggle selection off
    } else {
      _selectedCategoryId = categoryId;
    }

    _setLoading(true);
    try {
      _recipes = await _supabaseService.getRecipes(categoryId: _selectedCategoryId);
    } catch (e) {
      _errorMessage = "Error in filtering category ID";
    } finally {
      _setLoading(false);
    }
  }

  // 4. Dynamic Portion Scaler (+ / - Servings)
  void updateServings(int delta) {
    if (_currentServings + delta >= 1) {
      _currentServings += delta;
      notifyListeners();
    }
  }

  void resetServings() {
    _currentServings = 1;
    notifyListeners();
  }

  // 5. Hive Local Offline Favorites Management
  Future<void> toggleFavorite(RecipeModel recipe) async {
    await _hiveService.toggleFavorite(recipe);
    loadFavorites();
  }

  bool isFavorite(String recipeId) {
    return _hiveService.isFavorite(recipeId);
  }

  void loadFavorites() {
    _favoritesRecipes = _hiveService.getFavorites();
    notifyListeners();
  }

  // Helper private method for Loading State
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}