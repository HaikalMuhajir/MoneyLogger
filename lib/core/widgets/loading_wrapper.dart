// lib/core/widgets/loading_wrapper.dart

import 'package:flutter/material.dart';

/// Widget wrapper untuk mencegah infinite loading
class LoadingWrapper<T> extends StatelessWidget {
  final Future<List<T>> future;
  final Widget Function(List<T> data) builder;
  final Widget Function(String error) errorBuilder;
  final Widget Function() emptyBuilder;
  final Duration timeout;

  const LoadingWrapper({
    super.key,
    required this.future,
    required this.builder,
    required this.errorBuilder,
    required this.emptyBuilder,
    this.timeout = const Duration(seconds: 5),
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future.timeout(
        timeout,
        onTimeout: () {
          debugPrint('LoadingWrapper: Timeout reached, returning empty list');
          return <T>[];
        },
      ),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Memuat data...'),
              ],
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          debugPrint('LoadingWrapper error: ${snapshot.error}');
          return errorBuilder(snapshot.error.toString());
        }

        // Data state
        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return emptyBuilder();
        }

        return builder(data);
      },
    );
  }
}

/// Widget untuk menampilkan error state yang konsisten
class ErrorStateWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
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
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
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
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Coba Lagi'),
            ),
        ],
      ),
    );
  }
}

/// Widget untuk menampilkan empty state yang konsisten
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.onAction,
    this.actionText = 'Tambah Data',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: Colors.blue[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionText),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
