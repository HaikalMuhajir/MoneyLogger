import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:money_logger/features/auth/data/repository/auth_repository_impl.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Tidak perlu jika menggunakan UserEntity

// --- CONFIG & CORE ---
// File yang di-generate oleh flutterfire configure
import 'firebase_options.dart';

// --- HIVE & DOMAIN MODELS ---
// Perhatian: Karena fokus hanya Auth, kita buat placeholder model agar bisa dikompilasi.
import 'features/category/domain/entities/category_entity.dart';
import 'features/expense/domain/entities/expense_entity.dart';

// --- AUTH & PRESENTATION ---
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/entities/user_entity.dart';

// --- PLACEHOLDER UNTUK KOMPILASI ---
import 'features/expense/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. INISIALISASI FIREBASE
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2. INISIALISASI HIVE & DAFTARKAN ADAPTERS
    await Hive.initFlutter();

    // HAPUS TANDA KOMENTAR (//) SETELAH FILE .g.dart MUNCUL DAN DIIMPOR!
    // Hive.registerAdapter(CategoryAdapter());
    // Hive.registerAdapter(ExpenseAdapter());

    // 3. BUKA BOXES HIVE
    // await Hive.openBox<Category>('categories');
    // await Hive.openBox<Expense>('expenses');
  } catch (e) {
    debugPrint('Gagal Inisialisasi Layanan: $e');
    // Tambahkan notifikasi error ke user jika inisialisasi gagal total
  }

  runApp(
    // Riverpod memerlukan ProviderScope di root aplikasi
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// ------------------------------------
// MyApp: Menentukan Tema dan Root Widget
// ------------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyLogger',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // AppRoot akan menangani navigasi Login/Home
      home: const AppRoot(),
    );
  }
}

// ------------------------------------
// AppRoot: Penentu Navigasi Utama (Router)
// ------------------------------------

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mendengarkan stream status otentikasi dari Lapisan Domain
    final authStateStream = ref.watch(authRepositoryProvider).authStateChanges;

    return StreamBuilder<UserEntity?>(
      stream: authStateStream,
      builder: (context, snapshot) {
        // 1. Sedang Loading (Menunggu respons Firebase)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo))),
          );
        }

        // 2. Sudah Login (UserEntity ada)
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage(); // Navigasi ke Beranda
        }

        // 3. Belum Login (UserEntity null)
        else {
          return const LoginPage(); // Navigasi ke Layar Login
        }
      },
    );
  }
}
