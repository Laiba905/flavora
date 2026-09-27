import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe_model.dart';

class HiveService {
  static const String favoritesBoxName = 'favorites_box';

  // open box
  Box<RecipeModel> get _favoritesBox => Hive.box<RecipeModel>(favoritesBoxName);

  // toggle fav (add or remove)
  Future<void> toggleFavorite(RecipeModel recipe) async{
    if(_favoritesBox.containsKey(recipe.id)){
      await _favoritesBox.delete(recipe.id);
    } else{
      await _favoritesBox.put(recipe.id, recipe);
    }
  }

  // check if recipe is fav
  bool isFavorite(String recipeId){
    return _favoritesBox.containsKey(recipeId);
  }

  // get all favs recipes
  List<RecipeModel> getFavorites(){
    return _favoritesBox.values.toList();
  }

}