import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final Dio _dio = Dio(); // For actual internet connectivity check
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();
  bool _isInitialized = false;

  Stream<bool> get connectionStream => _connectionStatusController.stream;

  bool get isConnected {
    return !_connectionStatus.contains(ConnectivityResult.none);
  }

  Future<bool> checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _connectionStatus = results;

      // Check if device has connectivity but also test actual internet access
      if (isConnected) {
        final hasInternet = await _testInternetConnectivity();
        _connectionStatusController.add(hasInternet);
        return hasInternet;
      } else {
        _connectionStatusController.add(false);
        return false;
      }
    } catch (e) {
      _connectionStatus = [ConnectivityResult.none];
      _connectionStatusController.add(false);
      return false;
    }
  }

  /// Test actual internet connectivity by making a lightweight request
  Future<bool> _testInternetConnectivity() async {
    try {
      // Use a reliable endpoint for connectivity check
      final response = await _dio.get(
        'https://www.google.com',
        options: Options(
          receiveTimeout: Duration(seconds: 5),
          sendTimeout: Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      // Try alternative endpoint
      try {
        final response = await _dio.get(
          'https://jsonplaceholder.typicode.com/posts/1',
          options: Options(
            receiveTimeout: Duration(seconds: 5),
            sendTimeout: Duration(seconds: 5),
          ),
        );
        return response.statusCode == 200;
      } catch (e2) {
        return false;
      }
    }
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      await checkInitialConnection(); // Check initial connection
      _isInitialized = true;
    }

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((results) async {
      _connectionStatus = results;

      // Test actual internet when connectivity changes
      if (isConnected) {
        final hasInternet = await _testInternetConnectivity();
        _connectionStatusController.add(hasInternet);
      } else {
        _connectionStatusController.add(false);
      }
    });
  }

  void dispose() {
    _connectivitySubscription.cancel();
    _connectionStatusController.close();
  }

  /// Wait for connectivity with timeout
  Future<bool> waitForConnectivity(
      {Duration timeout = const Duration(seconds: 30)}) async {
    if (isConnected) return true;

    final completer = Completer<bool>();
    late StreamSubscription subscription;

    subscription = connectionStream.listen((isConnected) {
      if (isConnected) {
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      }
    });

    // Timeout fallback
    Timer(timeout, () {
      subscription.cancel();
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    return completer.future;
  }

  /// Get human-readable connection status
  String getConnectionStatusText() {
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    } else if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (_connectionStatus.contains(ConnectivityResult.bluetooth)) {
      return 'Bluetooth';
    } else if (_connectionStatus.contains(ConnectivityResult.other)) {
      return 'Other';
    } else {
      return 'No Connection';
    }
  }
}
