import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/utils/helpers.dart';
import '../../models/content_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

/// Waste Reduction Tracker screen.
class WasteTrackerScreen extends StatefulWidget {
  const WasteTrackerScreen({super.key});

  @override
  State<WasteTrackerScreen> createState() => _WasteTrackerScreenState();
}

class _WasteTrackerScreenState extends State<WasteTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waste Reduction Tracker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildChart(),
            const SizedBox(height: 16),
            _buildCategoryStats(),
            const SizedBox(height: 16),
            SectionHeader(title: 'Recent Records'),
            _buildRecentRecords(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        return GlassmorphismCard(
          child: Column(
            children: [
              ScoreCircle(
                score: data.totalWasteReduced > 0 ? (data.totalWasteReduced / 50 * 100).clamp(0, 100) : 0,
                size: 100,
                label: 'Waste Score',
              ),
              const SizedBox(height: 12),
              Text(
                '${data.totalWasteReduced.toStringAsFixed(2)} kg',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const Text('Total Waste Reduced'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChart() {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        final categories = [
          ('Recycled', data.recycledWaste, Colors.green),
          ('Composted', data.compostedWaste, Colors.brown),
          ('Plastic ↓', data.plasticReduced, Colors.blue),
          ('Paper ↓', data.paperReduced, Colors.orange),
        ];
        return GlassmorphismCard(
          child: SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: categories.asMap().entries.map((entry) {
                  final value = entry.value.$2 > 0 ? entry.value.$2 : 0.1;
                  return PieChartSectionData(
                    value: value,
                    color: entry.value.$3,
                    title: '${entry.value.$2.toStringAsFixed(1)}kg',
                    titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                    radius: 60,
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryStats() {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        return Row(
          children: [
            _buildStatBox('Recycled', data.recycledWaste, Icons.recycling, Colors.green),
            const SizedBox(width: 8),
            _buildStatBox('Composted', data.compostedWaste, Icons.compost, Colors.brown),
            const SizedBox(width: 8),
            _buildStatBox('Plastic', data.plasticReduced, Icons.remove_circle_outline, Colors.blue),
            const SizedBox(width: 8),
            _buildStatBox('Paper', data.paperReduced, Icons.article_outlined, Colors.orange),
          ],
        );
      },
    );
  }

  Widget _buildStatBox(String label, double value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text('${value.toStringAsFixed(1)}kg', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRecords() {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        if (data.wasteRecords.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.recycling_outlined,
            title: 'No Records',
            subtitle: 'Tap + to log your waste reduction activities.',
          );
        }
        return Column(
          children: data.wasteRecords.take(5).map((record) {
            return GlassmorphismCard(
              child: ListTile(
                leading: const Icon(Icons.recycling, color: AppColors.primary),
                title: Text(record.item),
                subtitle: Text('${record.category} • ${Formatters.formatDate(record.date)}'),
                trailing: Text(
                  '${record.weight.toStringAsFixed(2)} kg',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showAddDialog() {
    String category = 'recycled';
    final itemController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Add Waste Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['recycled', 'composting', 'plastic_reduction', 'paper_reduction']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.replaceAll('_', ' '))))
                    .toList(),
                onChanged: (v) => setStateDialog(() => category = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: itemController,
                decoration: const InputDecoration(labelText: 'Item'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final weight = double.tryParse(weightController.text);
                if (weight == null || itemController.text.isEmpty) return;
                final userId = context.read<AuthProvider>().user?.uid ?? '';
                await context.read<DataProvider>().addWasteRecord(WasteRecord(
                  userId: userId,
                  category: category,
                  item: itemController.text,
                  weight: weight,
                  date: DateTime.now(),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
