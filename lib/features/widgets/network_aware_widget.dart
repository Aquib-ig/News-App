// lib/core/widgets/network_aware_widget.dart
import 'package:flutter/material.dart';
import 'package:news_app/core/services/netwrok_service.dart';
import 'package:news_app/core/themes/app_colors.dart';

class NetworkAwareWidget extends StatefulWidget {
  final Widget child;

  const NetworkAwareWidget({
    super.key,
    required this.child,
  });

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  final NetworkService _networkService = NetworkService();

  @override
  void dispose() {
    _networkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _networkService,
      builder: (context, _) {
        if (!_networkService.isOnline) {
          return _buildOfflineScreen(context);
        }
        return widget.child;
      },
    );
  }

  Widget _buildOfflineScreen(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off,
                  size: 100,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                const SizedBox(height: 32),
                Text(
                  "No Internet Connection",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Please check your internet connection and try again",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _networkService.checkConnection();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Try Again"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
