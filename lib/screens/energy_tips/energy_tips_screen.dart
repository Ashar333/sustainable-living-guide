import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/data_provider.dart';

/// Energy Conservation Tips screen.
class EnergyTipsScreen extends StatefulWidget {
  const EnergyTipsScreen({super.key});

  @override
  State<EnergyTipsScreen> createState() => _EnergyTipsScreenState();
}

class _EnergyTipsScreenState extends State<EnergyTipsScreen> {
  final _categories = ['All', 'home_energy', 'appliances', 'solar', 'water_conservation'];
  bool _showSaved = false;

  @override
  void initState() {
    super.initState();
    context.read<DataProvider>().loadSavedTips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Conservation Tips'),
        actions: [
          IconButton(
            icon: Icon(_showSaved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () => setState(() => _showSaved = !_showSaved),
          ),
        ],
      ),
      body: Column(
        children: [
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
                    final isSelected = data.energyTips.isNotEmpty && 
                        (_showSaved ? true : (data.filteredTips.isEmpty ? true : data.filteredTips.first.category == cat || cat == 'All'));
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(cat.replaceAll('_', ' ')),
                        selected: cat == 'All' || isSelected,
                        onSelected: (_) => data.setTipCategory(cat),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<DataProvider>(
              builder: (context, data, _) {
                final tips = _showSaved ? data.savedTips : data.filteredTips;
                if (tips.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.lightbulb_outline,
                    title: _showSaved ? 'No Saved Tips' : 'No Tips Available',
                    subtitle: _showSaved ? 'Save tips to view them here.' : 'Tips will appear here.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tips.length,
                  itemBuilder: (context, index) {
                    final tip = tips[index];
                    return GlassmorphismCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.lightbulb, color: Colors.amber),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tip.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(tip.description, style: const TextStyle(fontSize: 13)),
                                if (tip.potentialSavings > 0) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Potential savings: ${tip.potentialSavings.toStringAsFixed(0)} kWh/year',
                                    style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              data.savedTips.any((t) => t.id == tip.id)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: AppColors.primary,
                            ),
                            onPressed: () => data.toggleSaveTip(tip),
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
