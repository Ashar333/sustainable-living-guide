import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/data_provider.dart';

/// Progress Dashboard with comprehensive analytics.
class ProgressDashboardScreen extends StatelessWidget {
  const ProgressDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<DataProvider>(
          builder: (context, data, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall sustainability score
                GlassmorphismCard(
                  child: Column(
                    children: [
                      const Text('Overall Sustainability Score',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      ScoreCircle(
                        score: data.carbonScore.toDouble(),
                        size: 140,
                        label: 'Score',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Carbon Reduction - Line Chart
                SectionHeader(title: 'Carbon Emissions Breakdown'),
                GlassmorphismCard(
                  child: SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: data.transportEmissions > 0 ? data.transportEmissions : 1,
                            color: Colors.blue,
                            title: 'Transport',
                            titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                            radius: 70,
                          ),
                          PieChartSectionData(
                            value: data.electricityEmissions > 0 ? data.electricityEmissions : 1,
                            color: Colors.amber,
                            title: 'Electricity',
                            titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                            radius: 70,
                          ),
                          PieChartSectionData(
                            value: data.foodEmissions > 0 ? data.foodEmissions : 1,
                            color: Colors.orange,
                            title: 'Food',
                            titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                            radius: 70,
                          ),
                          PieChartSectionData(
                            value: data.waterEmissions > 0 ? data.waterEmissions : 1,
                            color: Colors.cyan,
                            title: 'Water',
                            titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                            radius: 70,
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 35,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Waste Reduction - Bar Chart
                SectionHeader(title: 'Waste Reduction'),
                GlassmorphismCard(
                  child: SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: [data.recycledWaste, data.compostedWaste, data.plasticReduced, data.paperReduced]
                                .reduce((a, b) => a > b ? a : b) *
                            1.3 +
                            1,
                        barGroups: [
                          _barGroup(0, data.recycledWaste, Colors.green),
                          _barGroup(1, data.compostedWaste, Colors.brown),
                          _barGroup(2, data.plasticReduced, Colors.blue),
                          _barGroup(3, data.paperReduced, Colors.orange),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                const labels = ['Recycled', 'Compost', 'Plastic', 'Paper'];
                                final idx = value.toInt();
                                if (idx >= 0 && idx < labels.length) {
                                  return Text(labels[idx], style: const TextStyle(fontSize: 10));
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
                ),
                const SizedBox(height: 16),

                // Challenge Completion
                SectionHeader(title: 'Challenge Completion'),
                GlassmorphismCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_events, color: AppColors.primary, size: 40),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data.completedChallenges} Completed',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(
                                '${data.participations.length} Total Participated',
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: data.participations.isNotEmpty
                            ? data.completedChallenges / data.participations.length
                            : 0,
                        backgroundColor: AppColors.accent,
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Summary stats
                SectionHeader(title: 'Summary'),
                Row(
                  children: [
                    Expanded(
                      child: GlassmorphismCard(
                        child: Column(
                          children: [
                            Text(
                              data.totalEmissions.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            const Text('kg CO₂ Total', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlassmorphismCard(
                        child: Column(
                          children: [
                            Text(
                              data.totalWasteReduced.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            const Text('kg Waste Saved', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y > 0 ? y : 0.1,
          color: color,
          width: 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}
