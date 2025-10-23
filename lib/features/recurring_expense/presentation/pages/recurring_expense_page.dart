// lib/features/recurring_expense/presentation/pages/recurring_expense_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/recurring_expense_entity.dart';
import '../../../auth/presentation/riverpod/auth_provider.dart';
import '../../data/repository/recurring_expense_repository_impl.dart';
import '../../../category/data/models/category_model.dart';
import '../../../../core/widgets/loading_wrapper.dart';

class RecurringExpensePage extends ConsumerStatefulWidget {
  const RecurringExpensePage({super.key});

  @override
  ConsumerState<RecurringExpensePage> createState() =>
      _RecurringExpensePageState();
}

class _RecurringExpensePageState extends ConsumerState<RecurringExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  RecurringFrequency _selectedFrequency = RecurringFrequency.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

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
        title: const Text('Pengeluaran Berulang'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: LoadingWrapper<RecurringExpense>(
        future: _loadRecurringExpenses(user.uid),
        builder: (recurringExpenses) =>
            _buildRecurringExpensesList(recurringExpenses),
        errorBuilder: (error) => ErrorStateWidget(
          error: error,
          onRetry: () => setState(() {}),
        ),
        emptyBuilder: () => EmptyStateWidget(
          title: 'Belum ada pengeluaran berulang',
          message:
              'Buat pengeluaran berulang untuk mengotomatisasi\npencatatan pengeluaran rutin Anda',
          icon: Icons.repeat,
          onAction: () => _showAddRecurringExpenseDialog(),
          actionText: 'Buat Pengeluaran Berulang',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecurringExpenseDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<List<RecurringExpense>> _loadRecurringExpenses(String userId) async {
    try {
      // Try to get data with timeout
      final stream = ref
          .read(recurringExpenseRepositoryProvider)
          .getRecurringExpenses(userId);

      return await stream.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('Recurring expense stream timeout - returning empty list');
          return <RecurringExpense>[];
        },
      );
    } catch (e) {
      debugPrint('Error loading recurring expenses: $e');
      // Return empty list as fallback
      return <RecurringExpense>[];
    }
  }

  // -------------------------------------
  // STATES & WIDGETS
  // -------------------------------------

  Widget _buildRecurringExpensesList(List<RecurringExpense> recurringExpenses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Daftar Pengeluaran Berulang',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800]),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recurringExpenses.length,
            itemBuilder: (context, index) {
              final recurringExpense = recurringExpenses[index];
              return _buildRecurringExpenseCard(recurringExpense);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringExpenseCard(RecurringExpense recurringExpense) {
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
                    recurringExpense.description,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      _handleRecurringExpenseAction(value, recurringExpense),
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
                  'Rp ${recurringExpense.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getFrequencyColor(recurringExpense.frequency)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getFrequencyText(recurringExpense.frequency),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getFrequencyColor(recurringExpense.frequency),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Dimulai: ${_formatDate(recurringExpense.startDate)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (recurringExpense.endDate != null)
              Text(
                'Berakhir: ${_formatDate(recurringExpense.endDate!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }

  Color _getFrequencyColor(RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return Colors.blue;
      case RecurringFrequency.weekly:
        return Colors.green;
      case RecurringFrequency.monthly:
        return Colors.orange;
      case RecurringFrequency.yearly:
        return Colors.purple;
      case RecurringFrequency.quarterly:
        return Colors.teal;
    }
  }

  String _getFrequencyText(RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return 'Harian';
      case RecurringFrequency.weekly:
        return 'Mingguan';
      case RecurringFrequency.monthly:
        return 'Bulanan';
      case RecurringFrequency.yearly:
        return 'Tahunan';
      case RecurringFrequency.quarterly:
        return 'Triwulan';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleRecurringExpenseAction(
      String action, RecurringExpense recurringExpense) {
    switch (action) {
      case 'edit':
        _showEditRecurringExpenseDialog(recurringExpense);
        break;
      case 'delete':
        _showDeleteConfirmation(recurringExpense);
        break;
    }
  }

  void _showAddRecurringExpenseDialog() {
    _descriptionController.clear();
    _amountController.clear();
    _selectedFrequency = RecurringFrequency.monthly;
    _startDate = DateTime.now();
    _endDate = null;
    _selectedCategoryId = null;

    showDialog(
      context: context,
      builder: (context) => _buildRecurringExpenseDialog(),
    );
  }

  void _showEditRecurringExpenseDialog(RecurringExpense recurringExpense) {
    _descriptionController.text = recurringExpense.description;
    _amountController.text = recurringExpense.amount.toString();
    _selectedFrequency = recurringExpense.frequency;
    _startDate = recurringExpense.startDate;
    _endDate = recurringExpense.endDate;
    _selectedCategoryId = recurringExpense.categoryId;

    showDialog(
      context: context,
      builder: (context) =>
          _buildRecurringExpenseDialog(recurringExpense: recurringExpense),
    );
  }

  Widget _buildRecurringExpenseDialog({RecurringExpense? recurringExpense}) {
    final categoriesBox = Hive.box<CategoryModel>('categories');
    final categories = categoriesBox.values.toList();

    return AlertDialog(
      title: Text(recurringExpense == null
          ? 'Buat Pengeluaran Berulang'
          : 'Edit Pengeluaran Berulang'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Deskripsi harus diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Jumlah harus diisi';
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
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategoryId = value),
                validator: (value) =>
                    value == null ? 'Kategori harus dipilih' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RecurringFrequency>(
                initialValue: _selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frekuensi',
                  border: OutlineInputBorder(),
                ),
                items: RecurringFrequency.values.map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(_getFrequencyText(frequency)),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedFrequency = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => _saveRecurringExpense(recurringExpense),
          child: Text(recurringExpense == null ? 'Buat' : 'Update'),
        ),
      ],
    );
  }

  Future<void> _saveRecurringExpense(RecurringExpense? recurringExpense) async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = ref.read(authNotifierProvider).user!;
        final repository = ref.read(recurringExpenseRepositoryProvider);

        final newRecurringExpense = RecurringExpense(
          id: recurringExpense?.id ?? const Uuid().v4(),
          description: _descriptionController.text,
          amount: double.parse(_amountController.text),
          frequency: _selectedFrequency,
          startDate: _startDate,
          endDate: _endDate,
          userId: user.uid,
          createdAt: recurringExpense?.createdAt ?? DateTime.now(),
          categoryId: _selectedCategoryId ?? '', // fallback ke empty string
        );

        if (recurringExpense == null) {
          await repository.addRecurringExpense(newRecurringExpense);
        } else {
          await repository.updateRecurringExpense(newRecurringExpense);
        }

        Navigator.pop(context);
        _descriptionController.clear();
        _amountController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showDeleteConfirmation(RecurringExpense recurringExpense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengeluaran Berulang'),
        content: Text(
            'Apakah Anda yakin ingin menghapus pengeluaran berulang "${recurringExpense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(recurringExpenseRepositoryProvider)
                    .deleteRecurringExpense(recurringExpense.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Pengeluaran berulang berhasil dihapus')),
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
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
