import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';

/// Settings screen with app preferences.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          Consumer<ThemeProvider>(
            builder: (context, theme, _) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle dark/light theme'),
                secondary: Icon(theme.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                value: theme.isDarkMode,
                activeColor: AppColors.primary,
                onChanged: (_) => theme.toggleTheme(),
              );
            },
          ),
          const Divider(),

          // Notifications section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive eco tips and updates'),
            secondary: const Icon(Icons.notifications),
            value: true,
            activeColor: AppColors.primary,
            onChanged: (_) {},
          ),
          SwitchListTile(
            title: const Text('Daily Reminders'),
            subtitle: const Text('Get reminded to log activities'),
            secondary: const Icon(Icons.alarm),
            value: true,
            activeColor: AppColors.primary,
            onChanged: (_) {},
          ),
          const Divider(),

          // Data section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Data & Privacy', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms & Conditions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Clear Local Cache'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Cache'),
                  content: const Text('This will clear all locally cached data. Your online data will not be affected.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cache cleared successfully')),
                        );
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),

          // Account section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Account', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text('Delete Account', style: TextStyle(color: AppColors.error)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.error),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text('Are you sure? This action is permanent and cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () async {
                        final auth = context.read<AuthProvider>();
                        if (auth.user != null) {
                          await auth.deleteAccount(auth.user!.uid);
                          await auth.logout();
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
                        }
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),

          // About section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('About', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('FAQ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.faq),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('App Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
