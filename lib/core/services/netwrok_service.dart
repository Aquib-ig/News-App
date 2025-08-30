// lib/core/services/network_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  NetworkService() {
    _initialize();
  }

  void _initialize() async {
    // Check initial connectivity
    final List<ConnectivityResult> result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);

    // Listen to connectivity changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final wasOnline = _isOnline;
    _isOnline = !result.contains(ConnectivityResult.none);
    
    // Only notify if status changed
    if (wasOnline != _isOnline) {
      notifyListeners();
    }
  }

  Future<bool> checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
    return _isOnline;
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
