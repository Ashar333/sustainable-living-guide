import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/data_provider.dart';

/// Sustainable Recipes & Meal Planning screen.
class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final _searchController = TextEditingController();
  final _categories = ['All', 'plant_based', 'organic', 'low_carbon'];
  bool _showFavorites = false;

  @override
  void initState() {
    super.initState();
    context.read<DataProvider>().loadFavoriteRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sustainable Recipes'),
        actions: [
          IconButton(
            icon: Icon(_showFavorites ? Icons.favorite : Icons.favorite_border),
            onPressed: () => setState(() => _showFavorites = !_showFavorites),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: EcoSearchBar(
              controller: _searchController,
              hintText: 'Search recipes...',
              onChanged: (v) => context.read<DataProvider>().searchRecipes(v),
            ),
          ),
          SizedBox(
            height: 45,
            child: Consumer<DataProvider>(
              builder: (context, data, _) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = data.recipeCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(cat.replaceAll('_', ' ')),
                        selected: isSelected,
                        onSelected: (_) => data.setRecipeCategory(cat),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<DataProvider>(
              builder: (context, data, _) {
                final recipes = _showFavorites ? data.favoriteRecipes : data.filteredRecipes;
                if (recipes.isEmpty) {
                  return EmptyStateWidget(
                    icon: _showFavorites ? Icons.favorite_border : Icons.restaurant_menu_outlined,
                    title: _showFavorites ? 'No Favorites' : 'No Recipes',
                    subtitle: _showFavorites
                        ? 'Add recipes to your favorites!'
                        : 'Recipes will appear here.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return GlassmorphismCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.restaurant, color: AppColors.primary, size: 40),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${recipe.prepTime}m prep • ${recipe.cookTime}m cook',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      '${recipe.servings} servings • ${recipe.carbonFootprint.toStringAsFixed(1)} kg CO₂',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  data.favoriteRecipes.any((r) => r.id == recipe.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                onPressed: () => data.toggleFavoriteRecipe(recipe),
                              ),
                            ],
                          ),
                          if (recipe.ingredients.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Ingredients: ${recipe.ingredients.take(3).join(", ")}...',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
