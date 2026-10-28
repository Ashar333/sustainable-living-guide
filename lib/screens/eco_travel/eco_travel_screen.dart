import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/data_provider.dart';

/// Eco Travel Suggestions screen.
class EcoTravelScreen extends StatefulWidget {
  const EcoTravelScreen({super.key});

  @override
  State<EcoTravelScreen> createState() => _EcoTravelScreenState();
}

class _EcoTravelScreenState extends State<EcoTravelScreen> {
  final _searchController = TextEditingController();
  final _categories = ['All', 'hotels', 'public_transport', 'carpool', 'tips'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eco Travel')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: EcoSearchBar(
              controller: _searchController,
              hintText: 'Search eco travel...',
              onChanged: (v) => context.read<DataProvider>().searchTravel(v),
            ),
          ),
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
                  child: Consumer<DataProvider>(
                    builder: (context, data, _) {
                      return ChoiceChip(
                        label: Text(cat.replaceAll('_', ' ')),
                        selected: data.ecoTravel.isNotEmpty,
                        onSelected: (_) => data.setTravelCategory(cat),
                        selectedColor: AppColors.primary,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<DataProvider>(
              builder: (context, data, _) {
                final travel = data.filteredTravel;
                if (travel.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.flight_takeoff,
                    title: 'No Travel Suggestions',
                    subtitle: 'Eco travel tips will appear here.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: travel.length,
                  itemBuilder: (context, index) {
                    final item = travel[index];
                    return GlassmorphismCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.flight_takeoff, color: AppColors.primary, size: 35),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                if (item.location.isNotEmpty)
                                  Text(item.location, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 14, color: Colors.amber),
                                    Text(' ${item.ecoRating}/5', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
