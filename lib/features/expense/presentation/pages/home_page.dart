import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Sesuaikan path import Auth Provider Anda
import '../../../auth/presentation/riverpod/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyLogger - Beranda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            // Tombol untuk menguji alur logout
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Selamat Datang! Auth Berhasil.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
