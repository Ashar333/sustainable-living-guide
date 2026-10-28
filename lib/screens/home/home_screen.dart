import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../providers/theme_provider.dart';

/// Main home dashboard screen.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final authProvider = context.read<AuthProvider>();
    final dataProvider = context.read<DataProvider>();
    if (authProvider.user != null) {
      dataProvider.listenToCarbonRecords(authProvider.user!.uid);
      dataProvider.listenToWasteRecords(authProvider.user!.uid);
      dataProvider.listenToUserChallenges(authProvider.user!.uid);
    }
    dataProvider.listenToProducts();
    dataProvider.listenToChallenges();
    dataProvider.listenToRecipes();
    dataProvider.listenToPosts();
    dataProvider.listenToArticles();
    dataProvider.listenToCertifications();
    dataProvider.listenToEnergyTips();
    dataProvider.listenToEcoTravel();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _DashboardContent(),
      const _ExploreContent(),
      const _CommunityContent(),
      const _ProfileContent(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Dashboard tab content.
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with greeting and settings
            _buildHeader(context),
            const SizedBox(height: 24),
            // Sustainability Score
            _buildScoreCard(context),
            const SizedBox(height: 16),
            // Quick Stats
            _buildQuickStats(context),
            const SizedBox(height: 24),
            // Quick Actions
            SectionHeader(
              title: 'Quick Actions',
              actionText: 'View All',
              onAction: () {},
            ),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            // Active Challenges
            SectionHeader(title: 'Active Challenges'),
            _buildChallengeProgress(context),
            const SizedBox(height: 24),
            // Tips
            SectionHeader(title: 'Eco Tip of the Day'),
            _buildEcoTip(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting,',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            Text(
              authProvider.user?.name ?? 'Eco Warrior',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () => themeProvider.toggleTheme(),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        return GlassmorphismCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              ScoreCircle(
                score: data.carbonScore.toDouble(),
                size: 100,
                label: 'Eco Score',
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sustainability Score',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total CO₂: ${data.totalEmissions.toStringAsFixed(1)} kg',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Waste Reduced: ${data.totalWasteReduced.toStringAsFixed(1)} kg',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: data.carbonScore / 100,
                      backgroundColor: AppColors.accent,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.directions_car,
                label: 'Transport',
                value: '${data.transportEmissions.toStringAsFixed(1)} kg',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                icon: Icons.bolt,
                label: 'Electricity',
                value: '${data.electricityEmissions.toStringAsFixed(1)} kg',
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                icon: Icons.restaurant,
                label: 'Food',
                value: '${data.foodEmissions.toStringAsFixed(1)} kg',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                icon: Icons.water_drop,
                label: 'Water',
                value: '${data.waterEmissions.toStringAsFixed(1)} kg',
                color: Colors.cyan,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.eco, 'label': 'Carbon\nTracker', 'route': AppRoutes.carbonTracker},
      {'icon': Icons.shopping_bag, 'label': 'Eco\nProducts', 'route': AppRoutes.products},
      {'icon': Icons.emoji_events, 'label': 'Challenges', 'route': AppRoutes.challenges},
      {'icon': Icons.recycling, 'label': 'Waste\nTracker', 'route': AppRoutes.wasteTracker},
      {'icon': Icons.restaurant_menu, 'label': 'Recipes', 'route': AppRoutes.recipes},
      {'icon': Icons.lightbulb, 'label': 'Energy\nTips', 'route': AppRoutes.energyTips},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, action['route'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action['icon'] as IconData,
                  size: 32,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  action['label'] as String,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChallengeProgress(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        if (data.participations.isEmpty) {
          return GlassmorphismCard(
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.emoji_events_outlined, size: 40, color: AppColors.primary),
                  const SizedBox(height: 8),
                  const Text('No active challenges'),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.challenges),
                    child: const Text('Browse Challenges'),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: data.participations.take(3).map((p) {
            final challenge = data.challenges
                .where((c) => c.id == p.challengeId)
                .firstOrNull;
            return GlassmorphismCard(
              child: ListTile(
                leading: const Icon(Icons.emoji_events, color: AppColors.primary),
                title: Text(challenge?.title ?? 'Challenge'),
                subtitle: LinearProgressIndicator(
                  value: p.progress,
                  backgroundColor: AppColors.accent,
                ),
                trailing: Text('${(p.progress * 100).toInt()}%'),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEcoTip(BuildContext context) {
    return GlassmorphismCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tips_and_updates, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reduce, Reuse, Recycle',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Switch to reusable bags and containers to reduce plastic waste by up to 40%.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Explore tab content.
class _ExploreContent extends StatelessWidget {
  const _ExploreContent();

  @override
  Widget build(BuildContext context) {
    final exploreItems = [
      {'icon': Icons.verified_outlined, 'label': 'Green Certifications', 'route': AppRoutes.certifications},
      {'icon': Icons.flight_takeoff, 'label': 'Eco Travel', 'route': AppRoutes.ecoTravel},
      {'icon': Icons.school_outlined, 'label': 'Learn & Educate', 'route': AppRoutes.educational},
      {'icon': Icons.bar_chart, 'label': 'Progress Dashboard', 'route': AppRoutes.progressDashboard},
      {'icon': Icons.photo_library_outlined, 'label': 'Gallery', 'route': AppRoutes.gallery},
      {'icon': Icons.article_outlined, 'label': 'Articles & News', 'route': AppRoutes.educational},
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: exploreItems.length,
              itemBuilder: (context, index) {
                final item = exploreItems[index];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, item['route'] as String),
                  child: GlassmorphismCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 40,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['label'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Community tab content.
class _CommunityContent extends StatelessWidget {
  const _CommunityContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Community',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.forum),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<DataProvider>(
              builder: (context, data, _) {
                if (data.posts.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.forum_outlined,
                    title: 'No Posts Yet',
                    subtitle: 'Be the first to share something with the community!',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: data.posts.length,
                  itemBuilder: (context, index) {
                    final post = data.posts[index];
                    return GlassmorphismCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                child: Text(post.userName[0].toUpperCase()),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.userName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _formatTime(post.createdAt),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(post.content),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.favorite_border, size: 20, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text('${post.likes}'),
                              const SizedBox(width: 16),
                              Icon(Icons.comment_outlined, size: 20, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text('${post.commentCount}'),
                            ],
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

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

/// Profile tab content.
class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.accent,
                      child: Text(
                        (auth.user?.name ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(fontSize: 40, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      auth.user?.name ?? 'User',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      auth.user?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            _buildProfileOption(context, Icons.person, 'Edit Profile', AppRoutes.profile),
            _buildProfileOption(context, Icons.settings, 'Settings', AppRoutes.settings),
            _buildProfileOption(context, Icons.info_outline, 'About Us', AppRoutes.about),
            _buildProfileOption(context, Icons.help_outline, 'FAQ', AppRoutes.faq),
            _buildProfileOption(context, Icons.contact_mail_outlined, 'Contact Us', AppRoutes.contact),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.isAdmin) {
                  return _buildProfileOption(context, Icons.admin_panel_settings, 'Admin Panel', AppRoutes.admin);
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text('Logout', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}

/// Stat card widget.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
