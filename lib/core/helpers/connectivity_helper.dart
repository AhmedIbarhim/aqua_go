import 'dart:async';
import 'dart:io';
import 'package:aqua_go/core/config/networking/endpoints.dart';
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

  /// Host probed for real internet reachability. The connectivity_plus stream
  /// only reports interface state and can MISS the reconnect transition on
  /// iOS/simulator — so we confirm with an actual DNS lookup of the API host.
  static const String _probeHost = Endpoints.host;

  /// While OFFLINE we poll reachability on this cadence to recover a missed
  /// stream event within seconds. The timer is cancelled the moment we are
  /// back online (battery-conscious — no polling while connected).
  static const Duration _offlineRecheckInterval = Duration(seconds: 3);

  /// Short timeout so a probe never blocks the recheck cadence.
  static const Duration _probeTimeout = Duration(seconds: 2);

  Timer? _offlineRecheckTimer;

  void init() {
    WidgetsBinding.instance.addObserver(this);
    _checkInitialConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    _stopOfflineRecheckTimer();
    _connectivityController.close();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      debugPrint("[ConnectivityHelper] Initial connectivity check results: $results");
      await _updateConnectionStatus(results);
    } catch (e) {
      debugPrint("[ConnectivityHelper] Error checking initial connectivity: $e");
    }
  }

  Future<void> _updateConnectionStatus(dynamic results) async {
    debugPrint("[ConnectivityHelper] _updateConnectionStatus called with results: $results (isBackground: $_isBackground)");

    // If the app is in background status, we force the state to be connected (true)
    if (_isBackground) {
      debugPrint("[ConnectivityHelper] App is in background. Forcing connection status to true.");
      _setConnected(true);
      return;
    }

    bool hasInterface = false;
    if (results is List) {
      hasInterface = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    } else if (results is ConnectivityResult) {
      hasInterface = results != ConnectivityResult.none;
    }

    // No interface at all → definitely offline; no need to probe.
    if (!hasInterface) {
      debugPrint("[ConnectivityHelper] No network interface. isConnected = false");
      _setConnected(false);
      return;
    }

    // Interface present — confirm with a real reachability probe. The stream
    // can fire "connected" before the link is actually usable, and (more
    // importantly here) can also fail to fire at all on reconnect, which is
    // why the offline recheck timer drives this same path.
    final reachable = await _isInternetReachable();
    debugPrint("[ConnectivityHelper] Interface up, reachability probe = $reachable");
    _setConnected(reachable);
  }

  /// Actual internet-reachability probe: a DNS lookup of the API host with a
  /// short timeout. Returns false on any failure (no DNS, no route, timeout).
  Future<bool> _isInternetReachable() async {
    try {
      final result = await InternetAddress.lookup(
        _probeHost,
      ).timeout(_probeTimeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      debugPrint("[ConnectivityHelper] Reachability probe error: $e");
      return false;
    }
  }

  void _setConnected(bool connected) {
    if (_isConnected != connected) {
      debugPrint("[ConnectivityHelper] Connection status changed from $_isConnected to $connected");
      _isConnected = connected;
      _connectivityController.add(_isConnected);
    }

    // Drive the recovery timer from the resulting state every time, so we
    // recover a missed reconnect even when the boolean did not change.
    if (_isConnected) {
      _stopOfflineRecheckTimer();
    } else if (!_isBackground) {
      _startOfflineRecheckTimer();
    }
  }

  /// Periodically re-probe while OFFLINE so a missed onConnectivityChanged
  /// event is recovered within a few seconds and the offline banner clears.
  void _startOfflineRecheckTimer() {
    if (_offlineRecheckTimer != null) return; // already running
    debugPrint("[ConnectivityHelper] Starting offline recheck timer (${_offlineRecheckInterval.inSeconds}s).");
    _offlineRecheckTimer = Timer.periodic(_offlineRecheckInterval, (_) async {
      if (_isConnected || _isBackground) {
        _stopOfflineRecheckTimer();
        return;
      }
      final reachable = await _isInternetReachable();
      if (reachable) {
        debugPrint("[ConnectivityHelper] Offline recheck recovered the connection.");
        _setConnected(true);
      }
    });
  }

  void _stopOfflineRecheckTimer() {
    if (_offlineRecheckTimer != null) {
      debugPrint("[ConnectivityHelper] Stopping offline recheck timer.");
      _offlineRecheckTimer?.cancel();
      _offlineRecheckTimer = null;
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
      // Stop polling while backgrounded — battery-conscious.
      _stopOfflineRecheckTimer();
      _setConnected(true);
    } else if (state == AppLifecycleState.resumed) {
      _isBackground = false;
      debugPrint("[ConnectivityHelper] App resumed (foregrounded). Re-checking connectivity.");
      _checkInitialConnectivity();
    }
  }
}
