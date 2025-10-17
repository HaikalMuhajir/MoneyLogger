// lib/features/auth/presentation/pages/registration_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Sesuaikan import path jika berbeda
import '../../presentation/riverpod/auth_provider.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Panggil fungsi sign up dari AuthNotifier
      await ref.read(authNotifierProvider.notifier).signUp(email, password);

      // Catatan: Setelah signUp sukses, AuthNotifier stream akan mendeteksi User baru.
      // Navigator akan menangani pengarahan ke HomePage.

      // Setelah pendaftaran selesai (walaupun ada error, user object belum null),
      // kita tunggu hingga state loading hilang dan periksa user.
      if (ref.read(authNotifierProvider).user != null) {
        // Jika berhasil (sudah ada user), Pop layar registrasi.
        // Screen Root akan otomatis mengarahkan ke HomePage.
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
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
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
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
                  decoration: const InputDecoration(
                      labelText: 'Password (min. 6 karakter)'),
                  obscureText: true,
                  validator: (val) =>
                      val!.length < 6 ? 'Password minimal 6 karakter' : null,
                ),
                const SizedBox(height: 32),
                if (authState.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submitRegistration,
                    child: const Text('Daftar'),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(), // Kembali ke Login
                  child: const Text('Sudah punya akun? Login di sini'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
