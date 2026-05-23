import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

class ConnectivityHelper with WidgetsBindingObserver {
  // Singleton pattern
  static final ConnectivityHelper _instance = ConnectivityHelper._internal();
  factory ConnectivityHelper() => _instance;
  ConnectivityHelper._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  bool _isBackground = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void init() {
    WidgetsBinding.instance.addObserver(this);
    _checkInitialConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    _connectivityController.close();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      debugPrint("[ConnectivityHelper] Initial connectivity check results: $results");
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint("[ConnectivityHelper] Error checking initial connectivity: $e");
    }
  }

  void _updateConnectionStatus(dynamic results) {
    debugPrint("[ConnectivityHelper] _updateConnectionStatus called with results: $results (isBackground: $_isBackground)");
    
    // If the app is in background status, we force the state to be connected (true)
    if (_isBackground) {
      debugPrint("[ConnectivityHelper] App is in background. Forcing connection status to true.");
      _setConnected(true);
      return;
    }

    bool hasConnection = false;
    if (results is List) {
      hasConnection = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    } else if (results is ConnectivityResult) {
      hasConnection = results != ConnectivityResult.none;
    }

    debugPrint("[ConnectivityHelper] Evaluated connection status: isConnected = $hasConnection");
    _setConnected(hasConnection);
  }

  void _setConnected(bool connected) {
    if (_isConnected != connected) {
      debugPrint("[ConnectivityHelper] Connection status changed from $_isConnected to $connected");
      _isConnected = connected;
      _connectivityController.add(_isConnected);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("[ConnectivityHelper] AppLifecycleState changed to: $state");
    // We only treat AppLifecycleState.paused as background state.
    // AppLifecycleState.inactive is used for keyboard/system transitions or overlays.
    if (state == AppLifecycleState.paused) {
      _isBackground = true;
      debugPrint("[ConnectivityHelper] App paused (backgrounded). Forcing connected to true.");
      _setConnected(true);
    } else if (state == AppLifecycleState.resumed) {
      _isBackground = false;
      debugPrint("[ConnectivityHelper] App resumed (foregrounded). Re-checking connectivity.");
      _checkInitialConnectivity();
    }
  }
}
