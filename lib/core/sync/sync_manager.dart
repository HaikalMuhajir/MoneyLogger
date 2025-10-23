// lib/core/sync/sync_manager.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class SyncManager {
  final Connectivity _connectivity = Connectivity();
  Timer? _syncTimer;
  bool _isOnline = false;
  bool _isSyncing = false;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  SyncManager() {
    _initializeConnectivity();
  }

  void _initializeConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _isOnline = result != ConnectivityResult.none;
        if (_isOnline) {
          _startPeriodicSync();
        } else {
          _stopPeriodicSync();
        }
      },
    );
  }

  void _startPeriodicSync() {
    _stopPeriodicSync();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_isOnline && !_isSyncing) {
        performSync();
      }
    });
  }

  void _stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<void> performSync() async {
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      // Sync expenses
      await _syncExpenses();

      // Sync categories
      await _syncCategories();

      // Sync budgets
      await _syncBudgets();

      // Sync recurring expenses
      await _syncRecurringExpenses();

      // Sync shared expenses
      await _syncSharedExpenses();

      // Sync photo attachments
      await _syncPhotoAttachments();
    } catch (e) {
      print('Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncExpenses() async {
    // Implementation for syncing expenses
    // This would sync pending local changes to remote
    // and pull remote changes to local
  }

  Future<void> _syncCategories() async {
    // Implementation for syncing categories
  }

  Future<void> _syncBudgets() async {
    // Implementation for syncing budgets
  }

  Future<void> _syncRecurringExpenses() async {
    // Implementation for syncing recurring expenses
  }

  Future<void> _syncSharedExpenses() async {
    // Implementation for syncing shared expenses
  }

  Future<void> _syncPhotoAttachments() async {
    // Implementation for syncing photo attachments
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _stopPeriodicSync();
  }
}

final syncManagerProvider = Provider<SyncManager>((ref) {
  final syncManager = SyncManager();
  ref.onDispose(() => syncManager.dispose());
  return syncManager;
});
