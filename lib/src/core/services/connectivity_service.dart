import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier();
});

enum ConnectivityStatus {
  online,
  offline;

  bool get isOnline => this == ConnectivityStatus.online;
}

class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityNotifier() : super(ConnectivityStatus.online) {
    _init();
  }

  StreamSubscription<ConnectivityResult>? _subscription;

  void _init() {
    _checkConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    state = result == ConnectivityResult.none 
      ? ConnectivityStatus.offline 
      : ConnectivityStatus.online;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
