// lib/core/network/firebase_connection_manager.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseConnectionManager {
  static bool _isInitialized = false;
  static bool _isConnected = false;
  static String? _lastError;

  /// Initialize Firebase connection
  static Future<bool> initialize() async {
    try {
      if (!_isInitialized) {
        await Firebase.initializeApp();
        _isInitialized = true;
        debugPrint('Firebase initialized successfully');
      }

      // Test connection
      await _testConnection();
      return _isConnected;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Firebase initialization failed: $e');
      return false;
    }
  }

  /// Test Firebase connection
  static Future<bool> _testConnection() async {
    try {
      // Test Firestore connection
      await FirebaseFirestore.instance
          .collection('test')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));

      _isConnected = true;
      debugPrint('Firebase connection test successful');
      return true;
    } catch (e) {
      _isConnected = false;
      _lastError = e.toString();
      debugPrint('Firebase connection test failed: $e');
      return false;
    }
  }

  /// Check if Firebase is connected
  static bool get isConnected => _isConnected;

  /// Get last error
  static String? get lastError => _lastError;

  /// Retry connection
  static Future<bool> retryConnection() async {
    _isConnected = false;
    return await _testConnection();
  }

  /// Get connection status
  static Map<String, dynamic> getConnectionStatus() {
    return {
      'isInitialized': _isInitialized,
      'isConnected': _isConnected,
      'lastError': _lastError,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
