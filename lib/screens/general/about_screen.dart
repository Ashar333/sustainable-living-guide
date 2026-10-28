import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/constants/app_constants.dart';

/// About Us screen.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.eco_rounded, size: 45, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            Center(child: Text('Version ${AppConstants.appVersion}', style: const TextStyle(color: AppColors.textSecondary))),
            const SizedBox(height: 24),
            Text('Our Mission', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'The Sustainable Living Guide is dedicated to helping individuals and communities make environmentally conscious decisions. Our mission is to empower people with the knowledge, tools, and motivation to reduce their environmental footprint and live more sustainably.',
            ),
            const SizedBox(height: 16),
            Text('What We Do', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              '• Track and reduce your carbon footprint\n'
              '• Discover eco-friendly products\n'
              '• Join sustainability challenges\n'
              '• Learn through educational content\n'
              '• Connect with an eco-conscious community\n'
              '• Plan sustainable meals\n'
              '• Monitor waste reduction progress',
            ),
            const SizedBox(height: 24),
            GlassmorphismCard(
              child: Column(
                children: [
                  const Text('Our Values', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _valueRow(Icons.eco, 'Sustainability', 'Committed to environmental stewardship'),
                  _valueRow(Icons.people, 'Community', 'Building a global eco-conscious network'),
                  _valueRow(Icons.school, 'Education', 'Empowering through knowledge'),
                  _valueRow(Icons.trending_up, 'Innovation', 'Leveraging technology for a greener future'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Together, we can make a difference.\n🌍 Every action counts.',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _valueRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

/// FAQ screen.
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _expandedIndex;

  final _faqs = [
    _FaqItem('What is the Sustainable Living Guide?', 'The Sustainable Living Guide is a comprehensive mobile application that helps you track your environmental impact, discover eco-friendly products, join sustainability challenges, and connect with a community of environmentally conscious individuals.'),
    _FaqItem('How is my carbon footprint calculated?', 'Your carbon footprint is calculated based on your transportation habits, electricity usage, food consumption, and water usage. We use scientifically-backed emission factors to estimate the CO₂ impact of each activity.'),
    _FaqItem('How do I join a challenge?', 'Navigate to the Challenges section from the home dashboard, browse available challenges, and tap "Join Challenge" on any challenge you\'d like to participate in.'),
    _FaqItem('Can I use the app offline?', 'Yes! The app stores your data locally using SQLite, so you can continue tracking your activities even without an internet connection. Your data will sync when you\'re back online.'),
    _FaqItem('How do I earn badges?', 'Badges are earned by completing sustainability challenges. Each challenge has specific tasks that, when completed, reward you with a badge and points.'),
    _FaqItem('Is my data secure?', 'Yes, all your data is securely stored in Firebase with industry-standard encryption. We never share your personal information with third parties.'),
    _FaqItem('How can I contact support?', 'You can reach our support team through the Contact Us page in the app, or by emailing support@sustainableliving.guide.'),
    _FaqItem('Can I delete my account?', 'Yes, you can delete your account from the Settings page. All your data will be permanently removed from our servers.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return GlassmorphismCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              title: Text(faq.question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              leading: const Icon(Icons.help_outline, color: AppColors.primary),
              initiallyExpanded: _expandedIndex == index,
              onExpansionChanged: (expanded) {
                setState(() => _expandedIndex = expanded ? index : null);
              },
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 56, right: 16, bottom: 12),
                  child: Text(faq.answer, style: const TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  _FaqItem(this.question, this.answer);
}
