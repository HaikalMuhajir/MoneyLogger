// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import RegistrationPage
import 'registration_page.dart';
// Sesuaikan import path jika berbeda
import '../../presentation/riverpod/auth_provider.dart';

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

    // Side Effect: Menampilkan pesan error
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
      // Navigasi ke Home ditangani oleh AppRoot di main.dart, BUKAN di sini
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const RegistrationPage()),
                    );
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
