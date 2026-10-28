import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/data_provider.dart';

/// Educational Content screen with articles, videos, and infographics.
class EducationalScreen extends StatefulWidget {
  const EducationalScreen({super.key});

  @override
  State<EducationalScreen> createState() => _EducationalScreenState();
}

class _EducationalScreenState extends State<EducationalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _showBookmarks = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<DataProvider>().loadBookmarkedArticles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn & Educate'),
        actions: [
          IconButton(
            icon: Icon(_showBookmarks ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () => setState(() => _showBookmarks = !_showBookmarks),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Articles', icon: Icon(Icons.article)),
            Tab(text: 'Videos', icon: Icon(Icons.play_circle)),
            Tab(text: 'Infographics', icon: Icon(Icons.image)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: EcoSearchBar(
              controller: _searchController,
              hintText: 'Search content...',
              onChanged: (v) => context.read<DataProvider>().searchArticles(v),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildArticlesTab(),
                _buildVideosTab(),
                _buildInfographicsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesTab() {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        final articles = _showBookmarks ? data.bookmarkedArticles : data.filteredArticles;
        if (articles.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.article_outlined,
            title: _showBookmarks ? 'No Bookmarks' : 'No Articles',
            subtitle: 'Educational articles will appear here.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return GlassmorphismCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.article, color: AppColors.primary, size: 35),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(article.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('By ${article.authorName} • ${article.readTime} min read',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          data.bookmarkedArticles.any((a) => a.id == article.id)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: AppColors.primary,
                        ),
                        onPressed: () => data.toggleBookmark(article),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.content.length > 150 ? '${article.content.substring(0, 150)}...' : article.content,
                    style: const TextStyle(fontSize: 13),
                  ),
                  if (article.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: article.tags.take(3).map((tag) {
                        return Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 10)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVideosTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_circle_outline, size: 80, color: AppColors.primary),
          SizedBox(height: 16),
          Text('Educational Videos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 8),
          Text('Video content coming soon!', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildInfographicsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 80, color: AppColors.primary),
          SizedBox(height: 16),
          Text('Infographics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 8),
          Text('Infographic content coming soon!', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
