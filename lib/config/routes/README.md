# 🛣️ Routing System - MoneyLogger

Sistem routing yang terpusat dan modular untuk aplikasi MoneyLogger.

## 📁 Struktur File

```
lib/config/routes/
├── app_routes.dart          # Definisi route constants
├── route_generator.dart    # Generator untuk named routes
├── navigation_service.dart  # Service untuk navigasi
└── README.md              # Dokumentasi ini
```

## 🚀 Cara Penggunaan

### 1. Import Navigation Service
```dart
import 'package:money_logger/config/routes/navigation_service.dart';
import 'package:money_logger/config/routes/app_routes.dart';
```

### 2. Navigasi Sederhana
```dart
// Navigasi ke halaman statistik
NavigationService.goToStatistics();

// Navigasi ke halaman tambah expense
NavigationService.goToAddExpense();

// Navigasi dengan parameter
NavigationService.goToEditExpense(expense);
```

### 3. Navigasi Manual
```dart
// Push named route
NavigationService.pushNamed(AppRoutes.statistics);

// Push dengan arguments
NavigationService.pushNamed(
  AppRoutes.editExpense,
  arguments: {'expense': expense},
);

// Replace route
NavigationService.pushReplacementNamed(AppRoutes.home);

// Clear stack dan navigate
NavigationService.pushNamedAndRemoveUntil(AppRoutes.login);
```

## 📋 Daftar Routes

### Auth Routes
- `/login` - Halaman login
- `/register` - Halaman registrasi
- `/user-profile` - Profil pengguna

### Main Routes
- `/` - Home page
- `/splash` - Splash screen

### Expense Routes
- `/expense/add` - Tambah pengeluaran
- `/expense/edit` - Edit pengeluaran
- `/expense/details` - Detail pengeluaran

### Management Routes
- `/category/management` - Kelola kategori
- `/budget/management` - Kelola budget

### Analytics Routes
- `/statistics` - Statistik dasar
- `/analytics/advanced` - Analitik lanjutan

### Other Routes
- `/export/data` - Export data
- `/recurring-expense` - Pengeluaran berulang
- `/shared-expense` - Pengeluaran bersama

## 🔧 Konfigurasi

### MaterialApp Setup
```dart
MaterialApp(
  initialRoute: AppRoutes.home,
  onGenerateRoute: AppRouteGenerator.generateRoute,
  navigatorKey: NavigationService.navigatorKey,
  // ... other config
)
```

### Route Generator
Semua route didefinisikan di `AppRouteGenerator.generateRoute()` dengan:
- Error handling untuk route yang tidak ditemukan
- Argument validation untuk route yang memerlukan parameter
- Consistent page transitions

## ✅ Keuntungan

1. **Centralized**: Semua route di satu tempat
2. **Type Safe**: Menggunakan constants untuk route names
3. **Maintainable**: Mudah menambah/mengubah route
4. **Testable**: Navigation service dapat di-mock untuk testing
5. **Consistent**: Semua navigasi menggunakan pattern yang sama

## 🐛 Error Handling

Route generator menangani error dengan:
- Route not found → Error page dengan tombol "Go Home"
- Missing arguments → Error message yang jelas
- Invalid arguments → Fallback ke home page

## 📝 Best Practices

1. **Selalu gunakan NavigationService** untuk navigasi
2. **Gunakan AppRoutes constants** untuk route names
3. **Validasi arguments** sebelum navigasi
4. **Handle navigation errors** dengan try-catch
5. **Test navigation flow** dalam unit tests
