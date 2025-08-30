import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:news_app/core/themes/app_colors.dart";
import "package:news_app/features/presentation/setting_screen/cubit/theme_cubit.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Settings",
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Header
            _buildSectionHeader(context, "App Settings"),

            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final brightness = MediaQuery.of(context).platformBrightness;
                final isDarkTheme =
                    themeMode == ThemeMode.dark ||
                    (themeMode == ThemeMode.system &&
                        brightness == Brightness.dark);

                return _buildSettingsTile(
                  context,
                  icon: isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                  title: "Dark Theme",
                  subtitle: isDarkTheme
                      ? "Dark mode enabled"
                      : "Light mode enabled",
                  trailing: Switch(
                    value: isDarkTheme,
                    onChanged: (value) {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                    activeThumbColor: AppColors.lightPrimary,
                  ),
                );
              },
            ),

            // Notifications
            _buildSettingsTile(
              context,
              icon: Icons.notifications_outlined,
              title: "Notifications",
              subtitle: "Breaking news alerts",
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeThumbColor: AppColors.lightPrimary,
              ),
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader(context, "About"),

            _buildSettingsTile(
              context,
              icon: Icons.info_outline,
              title: "About App",
              subtitle: "News App v1.0.0",
              onTap: () {
                _showAboutDialog(context);
              },
            ),

            _buildSettingsTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              subtitle: "Read our privacy policy",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Privacy policy coming soon!"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.lightPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.lightPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.lightPrimary, size: 22),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        trailing:
            trailing ?? Icon(Icons.chevron_right, color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("About News App"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("News App v1.0.0"),
            SizedBox(height: 8),
            Text(
              "Stay updated with latest news from India and around the world.",
            ),
            SizedBox(height: 16),
            Text("Features:"),
            Text("• Indian and World news"),
            Text("• Category-wise news"),
            Text("• Search functionality"),
            Text("• Bookmark articles"),
            Text("• Dark/Light theme"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
