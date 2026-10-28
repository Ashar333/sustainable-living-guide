import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

/// Image Gallery screen with categories and full-screen preview.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _selectedCategory = 'All';
  final _categories = ['All', 'Nature', 'Recycling', 'Solar Energy', 'Organic Farming', 'Community'];

  // Placeholder gallery items with icons representing categories
  final _galleryItems = [
    _GalleryItem('Forest Conservation', 'Nature', Icons.forest),
    _GalleryItem('Ocean Cleanup', 'Nature', Icons.water),
    _GalleryItem('Recycling Plant', 'Recycling', Icons.recycling),
    _GalleryItem('Home Recycling', 'Recycling', Icons.delete_outline),
    _GalleryItem('Solar Panels', 'Solar Energy', Icons.solar_power),
    _GalleryItem('Wind Farm', 'Solar Energy', Icons.air),
    _GalleryItem('Organic Garden', 'Organic Farming', Icons.spa),
    _GalleryItem('Farm to Table', 'Organic Farming', Icons.grass),
    _GalleryItem('Beach Cleanup', 'Community', Icons.beach_access),
    _GalleryItem('Tree Planting', 'Community', Icons.park),
    _GalleryItem('Eco Workshop', 'Community', Icons.school),
    _GalleryItem('Green City', 'Nature', Icons.location_city),
  ];

  List<_GalleryItem> get _filteredItems {
    if (_selectedCategory == 'All') return _galleryItems;
    return _galleryItems.where((item) => item.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eco Gallery')),
      body: Column(
        children: [
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedCategory == cat ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return GestureDetector(
                  onTap: () => _showFullScreen(context, item),
                  child: GlassmorphismCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.2),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Icon(item.icon, size: 50, color: AppColors.primary),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreen(BuildContext context, _GalleryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: AppColors.accent.withOpacity(0.2),
              child: Icon(item.icon, size: 100, color: AppColors.primary),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(item.category, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryItem {
  final String title;
  final String category;
  final IconData icon;
  _GalleryItem(this.title, this.category, this.icon);
}
