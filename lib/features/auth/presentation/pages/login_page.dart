// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Sesuaikan import path jika berbeda
import '../../presentation/riverpod/auth_provider.dart';
// Import navigation service
import '../../../../config/routes/navigation_service.dart';
import '../../../../config/routes/app_routes.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // ... (controllers dan form key tetap sama)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Memanggil fungsi login dari AuthNotifier
      await ref.read(authNotifierProvider.notifier).signIn(email, password);
      // Root Widget akan menangani navigasi ke HomePage setelah stream Auth mendeteksi User
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Side Effect: Menampilkan pesan error dan handle navigation
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }

      // Jika login berhasil (ada user dan tidak loading),
      // AppRoot akan otomatis menangani navigasi ke HomePage
      if (next.user != null && !next.isLoading) {
        // Tidak perlu navigasi manual, AppRoot akan menangani ini
        debugPrint('Login berhasil, AppRoot akan menangani navigasi');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login MoneyLogger')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val!.isEmpty ? 'Masukkan email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (val) =>
                      val!.length < 6 ? 'Password minimal 6 karakter' : null,
                ),
                const SizedBox(height: 32),
                if (authState.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submitLogin,
                    child: const Text('Login'),
                  ),
                const SizedBox(height: 16),
                // Tombol Navigasi ke Halaman Daftar
                TextButton(
                  onPressed: () {
                    NavigationService.pushNamed(AppRoutes.register);
                  },
                  child: const Text('Belum punya akun? Daftar di sini'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
