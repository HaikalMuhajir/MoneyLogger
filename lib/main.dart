import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:money_logger/features/auth/data/repository/auth_repository_impl.dart';

// --- CONFIG & CORE ---
// File yang di-generate oleh flutterfire configure
import 'firebase_options.dart';
import 'core/network/firebase_connection_manager.dart';

// --- HIVE & DOMAIN MODELS ---
import 'features/category/data/models/category_model.dart';
import 'features/expense/data/models/expense_model.dart';

// --- AUTH & PRESENTATION ---
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/domain/entities/user_entity.dart';

// --- PLACEHOLDER UNTUK KOMPILASI ---
import 'features/expense/presentation/pages/home_page.dart';

// --- SPLASH SCREEN ---
// Splash screen functionality moved to AppRoot

// --- LOCALIZATION ---
import 'core/localization/app_localizations.dart';

// --- ROUTING ---
import 'config/routes/route_generator.dart';
import 'config/routes/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. INISIALISASI FIREBASE dengan connection manager
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Test Firebase connection
    final isFirebaseConnected = await FirebaseConnectionManager.initialize();
    if (!isFirebaseConnected) {
      debugPrint(
          'Firebase connection failed: ${FirebaseConnectionManager.lastError}');
    }

    // 2. INISIALISASI HIVE & DAFTARKAN ADAPTERS
    await Hive.initFlutter();

    // DAFTARKAN ADAPTERS HIVE
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(ExpenseModelAdapter());

    // 3. BUKA BOXES HIVE
    await Hive.openBox<CategoryModel>('categories');
    await Hive.openBox<ExpenseModel>('expenses');
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('id', ''),
      ],
      // Use named routes with centralized routing
      onGenerateRoute: AppRouteGenerator.generateRoute,
      navigatorKey: NavigationService.navigatorKey,
      // Use AppRoot to handle authentication routing
      home: const AppRoot(),
    );
  }
}

// ------------------------------------
// AppRoot: Penentu Navigasi Utama (Router)
// ------------------------------------

class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    // Start animation
    _animationController.forward();

    // Hide splash after animation completes
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen first
    if (_showSplash) {
      return _buildSplashScreen();
    }

    // After splash, handle authentication
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
          return const HomePage();
        }

        // 3. Belum Login (UserEntity null)
        else {
          return const LoginPage();
        }
      },
    );
  }

  Widget _buildSplashScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF272727) : Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          isDark
                              ? 'assets/images/splash_logo_dark.png'
                              : 'assets/images/splash_logo_white.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Name
                    Text(
                      'MoneyLogger',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      'Kelola Keuangan dengan Mudah',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Loading indicator
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? Colors.white : Colors.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
