import 'package:flutter/material.dart';
import '../../services/gemini_ai_service.dart';
import '../../models/recipe_model.dart';
import '../recipe_detail/recipe_detail_view.dart';
import '../../services/gemini_ai_service.dart';

class PantryInputView extends StatefulWidget {
  const PantryInputView({Key? key}) : super(key: key);

  @override
  State<PantryInputView> createState() => _PantryInputViewState();
}

class _PantryInputViewState extends State<PantryInputView> {
  final TextEditingController _ingredientController = TextEditingController();
  final List<String> _ingredients = ['Eggs', 'Milk', 'Cheese'];
  final GeminiAiService _aiService = GeminiAiService();
  bool _isLoading = false;

  void _addIngredient() {
    final text = _ingredientController.text.trim();
    if (text.isNotEmpty && !_ingredients.contains(text)) {
      setState(() {
        _ingredients.add(text);
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(String item) {
    setState(() {
      _ingredients.remove(item);
    });
  }

  Future<void> _generateRecipe() async {
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 1 ingredient!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final RecipeModel? generatedRecipe = await _aiService.generateRecipeFromIngredients(_ingredients);

    setState(() {
      _isLoading = false;
    });

    if (generatedRecipe != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeDetailView(recipe: generatedRecipe),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate AI recipe. Check API key or network.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantry-to-Plate AI Generator'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What is in your fridge?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add ingredients you have, and Gemini AI will create a custom recipe for you.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Chicken, Tomato, Rice',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _addIngredient(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _addIngredient,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _ingredients.map((item) {
                return Chip(
                  label: Text(item),
                  backgroundColor: Colors.orange.shade50,
                  deleteIconColor: Colors.redAccent,
                  onDeleted: () => _removeIngredient(item),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.auto_awesome, color: Colors.white),
                label: Text(
                  _isLoading ? 'AI Cooking Magic...' : 'Generate Recipe with AI',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _isLoading ? null : _generateRecipe,
              ),
            ),
          ],
        ),
      ),
    );
  }
}