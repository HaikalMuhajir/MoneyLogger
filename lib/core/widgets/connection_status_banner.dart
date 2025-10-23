// lib/core/widgets/connection_status_banner.dart

import 'package:flutter/material.dart';
import '../network/firebase_connection_manager.dart';

class ConnectionStatusBanner extends StatefulWidget {
  const ConnectionStatusBanner({super.key});

  @override
  State<ConnectionStatusBanner> createState() => _ConnectionStatusBannerState();
}

class _ConnectionStatusBannerState extends State<ConnectionStatusBanner> {
  bool _isConnected = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  void _checkConnection() {
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
    if (_isConnected) {
      return const SizedBox.shrink(); // Hide banner when connected
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: const Border(
          bottom: BorderSide(color: Colors.red, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Firebase Disconnected',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_lastError != null)
                  Text(
                    _lastError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: _retryConnection,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
