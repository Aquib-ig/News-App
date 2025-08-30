// lib/core/widgets/network_status_bar.dart
import 'package:flutter/material.dart';
import 'package:news_app/core/services/netwrok_service.dart';

class NetworkStatusBar extends StatefulWidget {
  final Widget child;

  const NetworkStatusBar({super.key, required this.child});

  @override
  State<NetworkStatusBar> createState() => _NetworkStatusBarState();
}

class _NetworkStatusBarState extends State<NetworkStatusBar> {
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
        return Column(
          children: [
            // Show red bar when offline
            if (!_networkService.isOnline)
              Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "No Internet Connection",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Main content
            Expanded(child: widget.child),
          ],
        );
      },
    );
  }
}
