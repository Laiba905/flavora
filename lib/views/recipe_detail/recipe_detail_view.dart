import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../models/recipe_model.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import 'widgets/macro_badge.dart';
import 'widgets/portion_scaler.dart';

class RecipeDetailView extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDetailView({super.key, required this.recipe});

  @override
  State<RecipeDetailView> createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> {
  int servings = 2;

  @override
  void initState() {
    super.initState();
    servings = 2;
  }

  String _formatQuantity(double amount) {
    if (amount % 1 == 0) return amount.toInt().toString();
    return amount.toStringAsFixed(1);
  }

  Future<void> _openYouTubeSearch() async {
    final query = '${widget.recipe.title} Recipe Tutorial';
    final url = Uri.parse('https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecipeViewModel>();
    final isFav = viewModel.isFavorite(widget.recipe.id);
    final double scaleFactor = servings / 2;

    // Step-by-Step Instructions parser
    final List<String> instructionSteps = widget.recipe.instructions
        .replaceAll(r'\n', '\n')
        .split('\n')
        .where((step) => step.trim().isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900), // Web/Tablet constraint
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Flexible Glassmorphic Sliver App Bar
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.4),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.4),
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? AppColors.accentRed : Colors.white,
                          size: 20,
                        ),
                        onPressed: () => viewModel.toggleFavorite(widget.recipe),
                      ),
                    ),
                  )
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.all(16),
                  title: Text(
                    widget.recipe.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 10, color: Colors.black87),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.recipe.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.chipBackground,
                          child: const Icon(Icons.restaurant, size: 80, color: AppColors.textMuted),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.2),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Detail Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cooking Time Pill
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  '${widget.recipe.cookingTimeMinutes} mins prep time',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Macros Row
                      Row(
                        children: [
                          Expanded(
                            child: MacroBadge(
                              label: 'Calories',
                              value: '${(widget.recipe.calories * scaleFactor).toInt()} kcal',
                              color: AppColors.primary,
                              icon: Icons.local_fire_department_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MacroBadge(
                              label: 'Protein',
                              value: '${_formatQuantity(widget.recipe.proteinGrams * scaleFactor)}g',
                              color: AppColors.accentBlue,
                              icon: Icons.fitness_center_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MacroBadge(
                              label: 'Carbs',
                              value: '${_formatQuantity(widget.recipe.carbsGrams * scaleFactor)}g',
                              color: AppColors.accentGreen,
                              icon: Icons.grain_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MacroBadge(
                              label: 'Fats',
                              value: '${_formatQuantity(widget.recipe.fatsGrams * scaleFactor)}g',
                              color: AppColors.accentRed,
                              icon: Icons.opacity_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Portion Scaler Widget
                      PortionScaler(
                        servings: servings,
                        onServingsChanged: (newServings) {
                          setState(() {
                            servings = newServings;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Description
                      if (widget.recipe.description.isNotEmpty) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.recipe.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Ingredients Section
                      const Text(
                        'Ingredients',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      widget.recipe.ingredients.isEmpty
                          ? const Text(
                        'No ingredients listed.',
                        style: TextStyle(color: AppColors.textMuted),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.recipe.ingredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = widget.recipe.ingredients[index];
                          final scaledAmount = ingredient.baseQuantity * scaleFactor;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                ingredient.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              trailing: Text(
                                '${_formatQuantity(scaledAmount)} ${ingredient.unit}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Instructions Steps
                      if (instructionSteps.isNotEmpty) ...[
                        const Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...instructionSteps.asMap().entries.map((entry) {
                          final stepIndex = entry.key + 1;
                          final stepText = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$stepIndex',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    stepText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],

                      // Always Visible YouTube Button Section
                      const Text(
                        'Video Tutorial',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF0000), // Official YouTube Red
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 24),
                          label: const Text(
                            'Watch Tutorial on YouTube',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: _openYouTubeSearch,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}