import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/carbon_product_challenge.dart';
import '../../models/content_models.dart';
import '../../providers/data_provider.dart';

/// Admin Panel screen for managing app content.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Products', icon: Icon(Icons.shopping_bag)),
            Tab(text: 'Challenges', icon: Icon(Icons.emoji_events)),
            Tab(text: 'Articles', icon: Icon(Icons.article)),
            Tab(text: 'Recipes', icon: Icon(Icons.restaurant_menu)),
            Tab(text: 'Users', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ProductsTab(),
          _ChallengesTab(),
          _ArticlesTab(),
          _RecipesTab(),
          _UsersTab(),
        ],
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddProductDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            ),
          ),
        ),
        Expanded(
          child: Consumer<DataProvider>(
            builder: (context, data, _) {
              if (data.products.isEmpty) {
                return const EmptyStateWidget(icon: Icons.shopping_bag, title: 'No Products', subtitle: 'Add products to manage.');
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: data.products.length,
                itemBuilder: (context, index) {
                  final product = data.products[index];
                  return GlassmorphismCard(
                    child: ListTile(
                      leading: const Icon(Icons.shopping_bag, color: AppColors.primary),
                      title: Text(product.name),
                      subtitle: Text('${product.category} • Rating: ${product.sustainabilityRating}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => data.deleteProduct(product.id!),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'Reusable Products');
    final linkCtrl = TextEditingController();
    final ratingCtrl = TextEditingController(text: '4.0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
              const SizedBox(height: 8),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Category')),
              const SizedBox(height: 8),
              TextField(controller: linkCtrl, decoration: const InputDecoration(labelText: 'Buy Link')),
              const SizedBox(height: 8),
              TextField(controller: ratingCtrl, decoration: const InputDecoration(labelText: 'Rating (1-5)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              await context.read<DataProvider>().addProduct(ProductModel(
                name: nameCtrl.text,
                description: descCtrl.text,
                category: catCtrl.text,
                imageUrl: '',
                sustainabilityRating: double.tryParse(ratingCtrl.text) ?? 4.0,
                buyLink: linkCtrl.text,
                createdAt: DateTime.now(),
              ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ChallengesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddChallengeDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Challenge'),
            ),
          ),
        ),
        Expanded(
          child: Consumer<DataProvider>(
            builder: (context, data, _) {
              if (data.challenges.isEmpty) {
                return const EmptyStateWidget(icon: Icons.emoji_events, title: 'No Challenges', subtitle: 'Add challenges to manage.');
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: data.challenges.length,
                itemBuilder: (context, index) {
                  final challenge = data.challenges[index];
                  return GlassmorphismCard(
                    child: ListTile(
                      leading: const Icon(Icons.emoji_events, color: AppColors.primary),
                      title: Text(challenge.title),
                      subtitle: Text('${challenge.category} • ${challenge.durationDays} days'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => data.deleteChallenge(challenge.id!),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddChallengeDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'general');
    final daysCtrl = TextEditingController(text: '7');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Challenge'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
              const SizedBox(height: 8),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Category')),
              const SizedBox(height: 8),
              TextField(controller: daysCtrl, decoration: const InputDecoration(labelText: 'Duration (days)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isEmpty) return;
              await context.read<DataProvider>().addChallenge(ChallengeModel(
                title: titleCtrl.text,
                description: descCtrl.text,
                category: catCtrl.text,
                durationDays: int.tryParse(daysCtrl.text) ?? 7,
                imageUrl: '',
                pointsReward: 100,
                badgeName: '${titleCtrl.text} Badge',
                startDate: DateTime.now(),
                endDate: DateTime.now().add(Duration(days: int.tryParse(daysCtrl.text) ?? 7)),
              ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ArticlesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddArticleDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Article'),
            ),
          ),
        ),
        Expanded(
          child: Consumer<DataProvider>(
            builder: (context, data, _) {
              if (data.articles.isEmpty) {
                return const EmptyStateWidget(icon: Icons.article, title: 'No Articles', subtitle: 'Add articles to manage.');
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: data.articles.length,
                itemBuilder: (context, index) {
                  final article = data.articles[index];
                  return GlassmorphismCard(
                    child: ListTile(
                      leading: const Icon(Icons.article, color: AppColors.primary),
                      title: Text(article.title),
                      subtitle: Text('${article.category} • ${article.readTime} min read'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => data.deleteArticle(article.id!),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddArticleDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'sustainability');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Article'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'Content'), maxLines: 4),
              const SizedBox(height: 8),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Category')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isEmpty) return;
              await context.read<DataProvider>().addArticle(ArticleModel(
                title: titleCtrl.text,
                content: contentCtrl.text,
                category: catCtrl.text,
                imageUrl: '',
                authorName: 'Admin',
                createdAt: DateTime.now(),
              ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _RecipesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddRecipeDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Recipe'),
            ),
          ),
        ),
        Expanded(
          child: Consumer<DataProvider>(
            builder: (context, data, _) {
              if (data.recipes.isEmpty) {
                return const EmptyStateWidget(icon: Icons.restaurant_menu, title: 'No Recipes', subtitle: 'Add recipes to manage.');
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: data.recipes.length,
                itemBuilder: (context, index) {
                  final recipe = data.recipes[index];
                  return GlassmorphismCard(
                    child: ListTile(
                      leading: const Icon(Icons.restaurant_menu, color: AppColors.primary),
                      title: Text(recipe.title),
                      subtitle: Text('${recipe.category} • ${recipe.servings} servings'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => data.deleteRecipe(recipe.id!),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddRecipeDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'plant_based');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Recipe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
              const SizedBox(height: 8),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Category')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isEmpty) return;
              await context.read<DataProvider>().addRecipe(RecipeModel(
                title: titleCtrl.text,
                description: descCtrl.text,
                category: catCtrl.text,
                imageUrl: '',
                createdAt: DateTime.now(),
              ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        return const EmptyStateWidget(
          icon: Icons.people,
          title: 'User Management',
          subtitle: 'User list will be loaded from Firestore.',
        );
      },
    );
  }
}
