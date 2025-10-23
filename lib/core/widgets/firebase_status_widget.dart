// lib/core/widgets/firebase_status_widget.dart

import 'package:flutter/material.dart';
import '../network/firebase_connection_manager.dart';

class FirebaseStatusWidget extends StatefulWidget {
  final Widget child;
  final bool showStatus;

  const FirebaseStatusWidget({
    super.key,
    required this.child,
    this.showStatus = false,
  });

  @override
  State<FirebaseStatusWidget> createState() => _FirebaseStatusWidgetState();
}

class _FirebaseStatusWidgetState extends State<FirebaseStatusWidget> {
  bool _isConnected = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final status = FirebaseConnectionManager.getConnectionStatus();
    setState(() {
      _isConnected = status['isConnected'] as bool;
      _lastError = status['lastError'] as String?;
    });
  }

  Future<void> _retryConnection() async {
    setState(() {
      _isConnected = false;
      _lastError = null;
    });

    final success = await FirebaseConnectionManager.retryConnection();
    setState(() {
      _isConnected = success;
      _lastError = success ? null : FirebaseConnectionManager.lastError;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showStatus) {
      return widget.child;
    }

    return Column(
      children: [
        // Firebase Status Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isConnected
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: _isConnected ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _isConnected ? Icons.cloud_done : Icons.cloud_off,
                color: _isConnected ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isConnected ? 'Firebase Connected' : 'Firebase Disconnected',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!_isConnected)
                TextButton(
                  onPressed: _retryConnection,
                  child: const Text('Retry'),
                ),
            ],
          ),
        ),
        // Main content
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Widget untuk menampilkan error koneksi Firebase
class FirebaseErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const FirebaseErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Firebase Connection Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (onRetry != null)
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Connection'),
            ),
        ],
      ),
    );
  }
}
