// lib/features/budget/presentation/pages/budget_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/budget_entity.dart';
import '../../../auth/presentation/riverpod/auth_provider.dart';
import '../../data/repository/budget_repository_impl.dart';
import '../../../../core/widgets/loading_wrapper.dart';

class BudgetManagementPage extends ConsumerStatefulWidget {
  const BudgetManagementPage({super.key});

  @override
  ConsumerState<BudgetManagementPage> createState() =>
      _BudgetManagementPageState();
}

class _BudgetManagementPageState extends ConsumerState<BudgetManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  Future<List<Budget>> _loadBudgets(String userId) async {
    try {
      return await ref
          .read(budgetRepositoryProvider)
          .getBudgets(userId)
          .first
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Error loading budgets: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Budget'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: LoadingWrapper<Budget>(
        future: _loadBudgets(user.uid),
        builder: (budgets) => _buildBudgetsList(budgets),
        errorBuilder: (error) => ErrorStateWidget(
          error: error,
          onRetry: () => setState(() {}),
        ),
        emptyBuilder: () => EmptyStateWidget(
          title: 'Belum ada budget',
          message:
              'Buat budget untuk mengontrol pengeluaran Anda\ndan capai tujuan keuangan yang diinginkan',
          icon: Icons.account_balance_wallet,
          onAction: () => _showAddBudgetDialog(),
          actionText: 'Buat Budget',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetsList(List<Budget> budgets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Daftar Budget',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800]),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return _buildBudgetCard(budget);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    final progress = budget.spentAmount / budget.totalAmount;
    final isOverBudget = progress > 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    budget.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleBudgetAction(value, budget),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rp ${budget.spentAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isOverBudget ? Colors.red : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Rp ${budget.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% digunakan',
              style: TextStyle(
                fontSize: 12,
                color: isOverBudget ? Colors.red : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBudgetAction(String action, Budget budget) {
    switch (action) {
      case 'edit':
        _showEditBudgetDialog(budget);
        break;
      case 'delete':
        _showDeleteConfirmation(budget);
        break;
    }
  }

  void _showAddBudgetDialog() {
    _nameController.clear();
    _amountController.clear();
    _selectedPeriod = BudgetPeriod.monthly;
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => _buildBudgetDialog(),
    );
  }

  void _showEditBudgetDialog(Budget budget) {
    _nameController.text = budget.name;
    _amountController.text = budget.totalAmount.toString();
    _selectedPeriod = budget.period;
    _startDate = budget.startDate;
    _endDate = budget.endDate;

    showDialog(
      context: context,
      builder: (context) => _buildBudgetDialog(budget: budget),
    );
  }

  Widget _buildBudgetDialog({Budget? budget}) {
    return AlertDialog(
      title: Text(budget == null ? 'Buat Budget' : 'Edit Budget'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Budget',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Nama budget harus diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Jumlah Budget',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty == true) return 'Jumlah budget harus diisi';
                if (double.tryParse(value!) == null) {
                  return 'Format tidak valid';
                }
                if (double.parse(value) <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BudgetPeriod>(
              initialValue: _selectedPeriod,
              decoration: const InputDecoration(
                labelText: 'Periode',
                border: OutlineInputBorder(),
              ),
              items: BudgetPeriod.values.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(period.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedPeriod = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => _saveBudget(budget),
          child: Text(budget == null ? 'Buat' : 'Update'),
        ),
      ],
    );
  }

  Future<void> _saveBudget(Budget? budget) async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = ref.read(authNotifierProvider).user!;
        final repository = ref.read(budgetRepositoryProvider);

        final newBudget = Budget(
          id: budget?.id ?? const Uuid().v4(),
          name: _nameController.text,
          totalAmount: double.parse(_amountController.text),
          spentAmount: budget?.spentAmount ?? 0.0,
          period: _selectedPeriod,
          startDate: _startDate,
          endDate: _endDate,
          userId: user.uid,
          createdAt: budget?.createdAt ?? DateTime.now(),
        );

        if (budget == null) {
          await repository.addBudget(newBudget);
        } else {
          await repository.updateBudget(newBudget);
        }

        Navigator.pop(context);
        _nameController.clear();
        _amountController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showDeleteConfirmation(Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Budget'),
        content:
            Text('Apakah Anda yakin ingin menghapus budget "${budget.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(budgetRepositoryProvider)
                    .deleteBudget(budget.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Budget berhasil dihapus')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
