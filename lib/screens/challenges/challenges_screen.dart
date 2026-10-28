import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/carbon_product_challenge.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

/// Sustainable Living Challenges screen.
class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eco Challenges')),
      body: Consumer<DataProvider>(
        builder: (context, data, _) {
          if (data.challenges.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.emoji_events_outlined,
              title: 'No Challenges Available',
              subtitle: 'Check back soon for new eco challenges!',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.challenges.length,
            itemBuilder: (context, index) {
              final challenge = data.challenges[index];
              final participation = data.participations
                  .where((p) => p.challengeId == challenge.id)
                  .firstOrNull;
              return GlassmorphismCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.emoji_events, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                challenge.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                '${challenge.durationDays} days • ${challenge.pointsReward} points',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            challenge.category,
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      challenge.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Tasks
                    if (challenge.tasks.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: challenge.tasks.take(3).map((task) {
                          return Chip(
                            label: Text(task, style: const TextStyle(fontSize: 10)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 12),
                    // Progress or join button
                    if (participation != null) ...[
                      LinearProgressIndicator(
                        value: participation.progress,
                        backgroundColor: AppColors.accent,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${participation.completedTasks}/${participation.totalTasks} tasks',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${(participation.progress * 100).toInt()}%',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ] else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final userId = context.read<AuthProvider>().user?.uid ?? '';
                            data.joinChallenge(ChallengeParticipation(
                              userId: userId,
                              challengeId: challenge.id ?? '',
                              totalTasks: challenge.tasks.length,
                              joinedAt: DateTime.now(),
                            ));
                          },
                          child: const Text('Join Challenge'),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
