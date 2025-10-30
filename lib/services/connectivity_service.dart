import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

/// Connectivity Service - Monitors network status
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _connectivity = Connectivity();
  final _logger = Logger();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      _isConnected = _isOnline(result);
      _connectionController.add(_isConnected);

      // Listen to connectivity changes
      _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
        final connected = results.any((result) => _isOnline([result]));
        if (_isConnected != connected) {
          _isConnected = connected;
          _connectionController.add(_isConnected);
          _logger.i('Connectivity changed: ${_isConnected ? "ONLINE" : "OFFLINE"}');
        }
      });

      _logger.i('ConnectivityService initialized. Connected: $_isConnected');
    } catch (e) {
      _logger.e('Failed to initialize ConnectivityService', error: e);
      _isConnected = true; // Assume connected if check fails
      _connectionController.add(_isConnected);
    }
  }

  /// Check if any connectivity result indicates online status
  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = _isOnline(result);
      return _isConnected;
    } catch (e) {
      _logger.e('Failed to check connectivity', error: e);
      return _isConnected; // Return last known state
    }
  }

  void dispose() {
    _connectionController.close();
  }
}
