import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/utils/helpers.dart';
import '../../models/carbon_product_challenge.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

/// Carbon Footprint Tracker screen.
class CarbonTrackerScreen extends StatefulWidget {
  const CarbonTrackerScreen({super.key});

  @override
  State<CarbonTrackerScreen> createState() => _CarbonTrackerScreenState();
}

class _CarbonTrackerScreenState extends State<CarbonTrackerScreen> {
  String _selectedPeriod = 'Daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carbon Footprint Tracker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            _buildPeriodSelector(),
            const SizedBox(height: 16),
            // Total emissions card
            _buildTotalCard(),
            const SizedBox(height: 16),
            // Chart
            _buildChart(),
            const SizedBox(height: 16),
            // Category breakdown
            _buildCategoryBreakdown(),
            const SizedBox(height: 16),
            // Suggestions
            SectionHeader(title: 'Reduction Suggestions'),
            _buildSuggestions(),
            const SizedBox(height: 16),
            // Recent records
            SectionHeader(title: 'Recent Records'),
            _buildRecentRecords(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: ['Daily', 'Weekly', 'Monthly'].map((period) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(period),
              selected: _selectedPeriod == period,
              onSelected: (selected) {
                if (selected) setState(() => _selectedPeriod = period);
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: _selectedPeriod == period ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTotalCard() {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        return GlassmorphismCard(
          child: Column(
            children: [
              ScoreCircle(
                score: data.carbonScore.toDouble(),
                size: 120,
                label: 'Carbon Score',
              ),
              const SizedBox(height: 12),
              Text(
                '${data.totalEmissions.toStringAsFixed(2)} kg CO₂',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              Text(
                'Total $_selectedPeriod Emissions',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
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
          ('Transport', data.transportEmissions, Colors.blue),
          ('Electricity', data.electricityEmissions, Colors.amber),
          ('Food', data.foodEmissions, Colors.orange),
          ('Water', data.waterEmissions, Colors.cyan),
        ];
        return GlassmorphismCard(
          child: SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: categories.map((c) => c.$2).reduce((a, b) => a > b ? a : b) * 1.2 + 1,
                barGroups: categories.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.$2,
                        color: entry.value.$3,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < categories.length) {
                          return Text(categories[idx].$1, style: const TextStyle(fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryBreakdown() {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        return GlassmorphismCard(
          child: Column(
            children: [
              _buildCategoryRow('Transport', data.transportEmissions, Icons.directions_car, Colors.blue),
              const Divider(),
              _buildCategoryRow('Electricity', data.electricityEmissions, Icons.bolt, Colors.amber),
              const Divider(),
              _buildCategoryRow('Food', data.foodEmissions, Icons.restaurant, Colors.orange),
              const Divider(),
              _buildCategoryRow('Water', data.waterEmissions, Icons.water_drop, Colors.cyan),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryRow(String label, double value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(
            '${value.toStringAsFixed(2)} kg',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        return Column(
          children: data.suggestions.map((s) {
            return GlassmorphismCard(
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: AppColors.warning),
                  const SizedBox(width: 12),
                  Expanded(child: Text(s)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRecentRecords() {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        if (data.carbonRecords.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.eco_outlined,
            title: 'No Records Yet',
            subtitle: 'Tap + to add your first carbon footprint record.',
          );
        }
        return Column(
          children: data.carbonRecords.take(5).map((record) {
            return GlassmorphismCard(
              child: ListTile(
                leading: Icon(_getCategoryIcon(record.category), color: AppColors.primary),
                title: Text('${record.subcategory} - ${record.amount} ${_getUnit(record.category)}'),
                subtitle: Text(Formatters.formatDate(record.date)),
                trailing: Text(
                  '${record.emissions.toStringAsFixed(2)} kg',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'transport': return Icons.directions_car;
      case 'electricity': return Icons.bolt;
      case 'food': return Icons.restaurant;
      case 'water': return Icons.water_drop;
      default: return Icons.eco;
    }
  }

  String _getUnit(String category) {
    switch (category) {
      case 'transport': return 'km';
      case 'electricity': return 'kWh';
      case 'food': return 'kg';
      case 'water': return 'liters';
      default: return '';
    }
  }

  void _showAddRecordDialog() {
    String selectedCategory = 'transport';
    String selectedSubcategory = 'car';
    final amountController = TextEditingController();

    final subcategories = {
      'transport': ['car', 'bus', 'train', 'flight', 'bicycle', 'walking'],
      'electricity': ['electricity'],
      'food': ['beef', 'poultry', 'fish', 'vegetables', 'fruits', 'dairy'],
      'water': ['water'],
    };

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Add Carbon Record'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: ['transport', 'electricity', 'food', 'water']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        setDialogState(() {
                          selectedCategory = v!;
                          selectedSubcategory = subcategories[v]!.first;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedSubcategory,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: (subcategories[selectedCategory] ?? [])
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setDialogState(() => selectedSubcategory = v!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount (${_getUnit(selectedCategory)})',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount == null) return;

                    double emissions;
                    switch (selectedCategory) {
                      case 'transport':
                        emissions = CarbonCalculator.calculateTransport(selectedSubcategory, amount);
                        break;
                      case 'electricity':
                        emissions = CarbonCalculator.calculateElectricity(amount);
                        break;
                      case 'food':
                        emissions = CarbonCalculator.calculateFood(selectedSubcategory, amount);
                        break;
                      case 'water':
                        emissions = CarbonCalculator.calculateWater(amount);
                        break;
                      default:
                        emissions = 0;
                    }

                    final userId = context.read<AuthProvider>().user?.uid ?? '';
                    final record = CarbonRecord(
                      userId: userId,
                      category: selectedCategory,
                      subcategory: selectedSubcategory,
                      amount: amount,
                      emissions: emissions,
                      date: DateTime.now(),
                    );

                    await context.read<DataProvider>().addCarbonRecord(record);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
