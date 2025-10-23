import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/riverpod/auth_provider.dart';
import '../../domain/entities/expense_entity.dart';
import '../../data/repository/expense_repository_impl.dart';
import '../../../category/data/repository/category_repository_impl.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../../core/util/date_helper.dart';
import '../../../../config/routes/navigation_service.dart';
import '../../../../core/network/firebase_connection_manager.dart';
import '../../../../core/widgets/connection_status_banner.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Future<Map<String, dynamic>> _loadHomeData(String userId) async {
    try {
      // Check Firebase connection first
      if (!FirebaseConnectionManager.isConnected) {
        debugPrint('Firebase not connected, retrying...');
        final isConnected = await FirebaseConnectionManager.retryConnection();
        if (!isConnected) {
          throw Exception(
              'Firebase connection failed: ${FirebaseConnectionManager.lastError}');
        }
      }

      final expenses = await ref
          .read(expenseRepositoryProvider)
          .getExpenses(userId)
          .first
          .timeout(const Duration(seconds: 5));

      final categories = await ref
          .read(categoryRepositoryProvider)
          .getCategories(userId)
          .first
          .timeout(const Duration(seconds: 5));

      return {
        'expenses': expenses,
        'categories': categories,
      };
    } catch (e) {
      debugPrint('Error loading home data: $e');
      return {
        'expenses': <Expense>[],
        'categories': <Category>[],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyLogger'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'statistics':
                  NavigationService.goToStatistics();
                  break;
                case 'analytics':
                  NavigationService.goToAnalytics();
                  break;
                case 'export':
                  NavigationService.goToExport();
                  break;
                case 'categories':
                  NavigationService.goToCategories();
                  break;
                case 'budgets':
                  NavigationService.goToBudgets();
                  break;
                case 'recurring':
                  NavigationService.goToRecurringExpense();
                  break;
                case 'shared':
                  NavigationService.goToSharedExpense();
                  break;
                case 'profile':
                  NavigationService.goToUserProfile();
                  break;
                case 'logout':
                  ref.read(authNotifierProvider.notifier).signOut();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'statistics',
                child: Row(
                  children: [
                    Icon(Icons.bar_chart),
                    SizedBox(width: 8),
                    Text('Statistik'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'analytics',
                child: Row(
                  children: [
                    Icon(Icons.analytics),
                    SizedBox(width: 8),
                    Text('Analitik Lanjutan'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category),
                    SizedBox(width: 8),
                    Text('Kelola Kategori'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'budgets',
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet),
                    SizedBox(width: 8),
                    Text('Budget'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'recurring',
                child: Row(
                  children: [
                    Icon(Icons.repeat),
                    SizedBox(width: 8),
                    Text('Pengeluaran Berulang'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'shared',
                child: Row(
                  children: [
                    Icon(Icons.people),
                    SizedBox(width: 8),
                    Text('Pengeluaran Bersama'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const ConnectionStatusBanner(),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _loadHomeData(user.uid),
              builder: (context, snapshot) {
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

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        const Text('Terjadi kesalahan',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(snapshot.error.toString(),
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600])),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final data = snapshot.data ??
                    {'expenses': <Expense>[], 'categories': <Category>[]};
                final expenses = data['expenses'] as List<Expense>;
                final categories = data['categories'] as List<Category>;

                final totalExpenses = expenses.fold<double>(
                    0.0, (sum, expense) => sum + expense.amount);
                return _buildHomeContent(expenses, categories, totalExpenses);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NavigationService.goToAddExpense().then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHomeContent(
      List<Expense> expenses, List<Category> categories, double totalExpenses) {
    return Column(
      children: [
        // Enhanced Summary Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pengeluaran',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateHelper.formatCurrency(totalExpenses),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                      'Transaksi', '${expenses.length}', Icons.receipt),
                  _buildStatCard(
                      'Kategori', '${categories.length}', Icons.category),
                  _buildStatCard(
                      'Rata-rata',
                      expenses.isNotEmpty
                          ? DateHelper.formatCurrency(
                              totalExpenses / expenses.length)
                          : 'Rp 0',
                      Icons.trending_up),
                ],
              ),
            ],
          ),
        ),

        // Quick Actions
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Tambah Pengeluaran',
                  Icons.add,
                  Colors.blue,
                  () => NavigationService.goToAddExpense(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Lihat Statistik',
                  Icons.bar_chart,
                  Colors.green,
                  () => NavigationService.goToStatistics(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Recent Expenses
        Expanded(
          child: expenses.isEmpty
              ? _buildEmptyState()
              : _buildExpensesList(expenses, categories),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada pengeluaran',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai catat pengeluaran Anda\ndan kelola keuangan dengan lebih baik',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => NavigationService.goToAddExpense(),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Pengeluaran'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(List<Expense> expenses, List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengeluaran Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () => NavigationService.goToStatistics(),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: expenses.length > 10 ? 10 : expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return _buildExpenseCard(expense, categories);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(Expense expense, List<Category> categories) {
    final category = categories.firstWhere(
      (cat) => cat.id == expense.categoryId,
      orElse: () => Category(
        id: '',
        name: 'Unknown',
        colorHex: '#9E9E9E',
        userId: '',
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getCategoryColor(category.id, categories).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(category.name),
            color: _getCategoryColor(category.id, categories),
            size: 24,
          ),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              category.name,
              style: TextStyle(
                color: _getCategoryColor(category.id, categories),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateHelper.formatDateTime(expense.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateHelper.formatCurrency(expense.amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
        onTap: () {
          NavigationService.goToEditExpense(expense);
        },
      ),
    );
  }

  Color _getCategoryColor(String categoryId, List<Category> categories) {
    try {
      final category = categories.firstWhere((cat) => cat.id == categoryId);
      return Color(int.parse(category.colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'makanan':
        return Icons.restaurant;
      case 'transportasi':
        return Icons.directions_car;
      case 'belanja':
        return Icons.shopping_bag;
      case 'hiburan':
        return Icons.movie;
      case 'kesehatan':
        return Icons.local_hospital;
      default:
        return Icons.category;
    }
  }
}
