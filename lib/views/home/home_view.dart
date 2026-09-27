import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import 'widgets/category_card.dart';
import 'widgets/recipe_card.dart';
import '../pantry_ai/pantry_input_view.dart';
import '../favorites/favorites_view.dart';
import '../profile/profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<RecipeViewModel>().fetchInitialData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    context.read<RecipeViewModel>().searchRecipes(query);
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    context.read<RecipeViewModel>().searchRecipes('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Dynamic Floating AI Button (Mobile vs Web responsive styling)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PantryInputView(),
            ),
          );
        },
        backgroundColor: Colors.orange,
        elevation: 4,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text(
          'AI Pantry',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<RecipeViewModel>(
          builder: (context, viewModel, child) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top User Profile Bar & Favorites Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hello Foodie 👋',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'What would you like to cook?',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Favorites Navigation Quick Button
                                IconButton(
                                  tooltip: 'Favorites',
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.surface,
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(10),
                                  ),
                                  icon: const Icon(
                                    Icons.favorite_rounded,
                                    color: Colors.redAccent,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const FavoritesView(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),

                                // Profile Navigation Avatar with Live Photo Sync
                                Consumer<AuthViewModel>(
                                  builder: (context, authVm, child) {
                                    final avatarUrl = authVm.userAvatarUrl;

                                    ImageProvider? avatarImage;
                                    if (avatarUrl != null && avatarUrl.isNotEmpty) {
                                      if (avatarUrl.startsWith('http')) {
                                        avatarImage = NetworkImage(avatarUrl);
                                      } else if (!kIsWeb) {
                                        avatarImage = FileImage(File(avatarUrl));
                                      } else {
                                        avatarImage = NetworkImage(avatarUrl);
                                      }
                                    }

                                    return GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const ProfileView(),
                                          ),
                                        );
                                        if (context.mounted) {
                                          context.read<AuthViewModel>().loadUserAvatar();
                                        }
                                      },
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: AppColors.primary.withValues(
                                          alpha: 0.15,
                                        ),
                                        backgroundImage: avatarImage,
                                        child: avatarImage == null
                                            ? const Icon(
                                          Icons.person_outline_rounded,
                                          color: AppColors.primary,
                                          size: 22,
                                        )
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Hybrid Search Field
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                onSubmitted: _onSearchSubmitted,
                                onChanged: (value) {
                                  if (value.trim().isEmpty) {
                                    context.read<RecipeViewModel>().searchRecipes('');
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search recipes, ingredients...',
                                  hintStyle: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: AppColors.textMuted,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      color: AppColors.textMuted,
                                      size: 20,
                                    ),
                                    onPressed: _clearSearch,
                                  )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Categories Title
                            const Text(
                              'Categories',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Horizontal Categories Bar
                            SizedBox(
                              height: 44,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: viewModel.categories.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    final bool isAllSelected =
                                        viewModel.selectedCategoryId == null;
                                    return GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        viewModel.selectCategory(null);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isAllSelected
                                              ? AppColors.primary
                                              : AppColors.surface,
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                          border: Border.all(
                                            color: isAllSelected
                                                ? AppColors.primary
                                                : AppColors.border,
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isAllSelected
                                                  ? AppColors.primary
                                                  .withValues(alpha: 0.3)
                                                  : Colors.black.withValues(
                                                alpha: 0.03,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            'All Recipes',
                                            style: TextStyle(
                                              color: isAllSelected
                                                  ? Colors.white
                                                  : AppColors.textPrimary,
                                              fontWeight: isAllSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  final category =
                                  viewModel.categories[index - 1];
                                  return CategoryCard(
                                    category: category,
                                    isSelected:
                                    viewModel.selectedCategoryId ==
                                        category.id,
                                    onTap: () {
                                      _searchController.clear();
                                      viewModel.selectCategory(category.id);
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Section Title
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? 'Search Results'
                                      : (viewModel.selectedCategoryId == null
                                      ? 'Popular Recipes'
                                      : 'Filtered Recipes'),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${viewModel.recipes.length} items',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    // Grid Content
                    if (viewModel.isLoading)
                      const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (viewModel.errorMessage != null)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: AppColors.accentRed,
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  viewModel.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => viewModel.fetchInitialData(),
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (viewModel.recipes.isEmpty)
                        const SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  size: 54,
                                  color: AppColors.textMuted,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No recipes found',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverLayoutBuilder(
                            builder: (context, constraints) {
                              // Ultra Responsive Column Calculations
                              int crossAxisCount = 2; // Mobile Standard
                              double childAspectRatio = 0.68;

                              if (constraints.crossAxisExtent > 1100) {
                                crossAxisCount = 5; // Desktop / Web Ultra Wide
                                childAspectRatio = 0.75;
                              } else if (constraints.crossAxisExtent > 800) {
                                crossAxisCount = 4; // Tablet Landscape / Large Screen
                                childAspectRatio = 0.74;
                              } else if (constraints.crossAxisExtent > 600) {
                                crossAxisCount = 3; // Tablet Portrait / Foldables
                                childAspectRatio = 0.72;
                              }

                              return SliverGrid(
                                gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: childAspectRatio,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                    final recipe = viewModel.recipes[index];
                                    return RecipeCard(recipe: recipe);
                                  },
                                  childCount: viewModel.recipes.length,
                                ),
                              );
                            },
                          ),
                        ),
                    const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}