import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/data_provider.dart';

/// Green Certification Guide screen.
class CertificationsScreen extends StatelessWidget {
  const CertificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Default certifications if none from Firestore
    final defaultCertifications = [
      _CertData('Energy Star', 'Certifies energy-efficient products that reduce greenhouse gas emissions.', 'Energy-efficient appliances save money and protect the environment.', Icons.bolt),
      _CertData('Fair Trade', 'Ensures fair wages and safe working conditions for producers in developing countries.', 'Support ethical production and fair wages for workers worldwide.', Icons.handshake),
      _CertData('Organic', 'Products grown without synthetic pesticides, fertilizers, or GMOs.', 'Healthier food choices with lower environmental impact.', Icons.spa),
      _CertData('FSC', 'Forest Stewardship Council certifies responsibly managed forests.', 'Ensures wood and paper products come from sustainable sources.', Icons.forest),
      _CertData('Rainforest Alliance', 'Promotes sustainable agriculture and forest management practices.', 'Protects ecosystems and supports rural communities.', Icons.nature_people),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Green Certifications')),
      body: Consumer<DataProvider>(
        builder: (context, data, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: defaultCertifications.length,
            itemBuilder: (context, index) {
              final cert = defaultCertifications[index];
              return GestureDetector(
                onTap: () => _showCertDetail(context, cert),
                child: GlassmorphismCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(cert.icon, color: AppColors.primary, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cert.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cert.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.primary),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCertDetail(BuildContext context, _CertData cert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cert.icon, color: AppColors.primary, size: 40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      cert.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(cert.description),
                  const SizedBox(height: 16),
                  Text(
                    'Benefits',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(cert.usage),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CertData {
  final String name;
  final String description;
  final String usage;
  final IconData icon;
  _CertData(this.name, this.description, this.usage, this.icon);
}
