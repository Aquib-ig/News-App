// lib/core/mixins/connectivity_mixin.dart
import 'package:connectivity_plus/connectivity_plus.dart';

mixin ConnectivityMixin {
  final Connectivity _connectivity = Connectivity();

  Future<bool> checkConnectivity() async {
    final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  String get noInternetMessage => "No internet connection. Please check your connection and try again.";
}
