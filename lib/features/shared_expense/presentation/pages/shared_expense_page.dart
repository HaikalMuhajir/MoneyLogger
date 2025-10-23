// lib/features/shared_expense/presentation/pages/shared_expense_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/shared_expense_entity.dart';
import '../../../auth/presentation/riverpod/auth_provider.dart';
import '../../data/repository/shared_expense_repository_impl.dart';

class SharedExpensePage extends ConsumerStatefulWidget {
  const SharedExpensePage({super.key});

  @override
  ConsumerState<SharedExpensePage> createState() => _SharedExpensePageState();
}

class _SharedExpensePageState extends ConsumerState<SharedExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _participantController = TextEditingController();

  List<String> _participants = [];

  Future<List<SharedExpense>> _loadSharedExpenses(String userId) async {
    try {
      return await ref
          .read(sharedExpenseRepositoryProvider)
          .getSharedExpenses(userId)
          .first
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Error loading shared expenses: $e');
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
        title: const Text('Pengeluaran Bersama'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<SharedExpense>>(
        future: _loadSharedExpenses(user.uid),
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
            return _buildErrorState(snapshot.error.toString());
          }

          final sharedExpenses = snapshot.data ?? [];
          return sharedExpenses.isEmpty
              ? _buildEmptyState()
              : _buildSharedExpensesList(sharedExpenses);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSharedExpenseDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text('Terjadi kesalahan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Coba Lagi'),
          ),
        ],
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
              color: Colors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people, size: 64, color: Colors.purple[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada pengeluaran bersama',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat pengeluaran bersama untuk membagi\nbiaya dengan teman atau keluarga',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddSharedExpenseDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Buat Pengeluaran Bersama'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedExpensesList(List<SharedExpense> sharedExpenses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Daftar Pengeluaran Bersama',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800]),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sharedExpenses.length,
            itemBuilder: (context, index) {
              final sharedExpense = sharedExpenses[index];
              return _buildSharedExpenseCard(sharedExpense);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSharedExpenseCard(SharedExpense sharedExpense) {
    final totalParticipants = sharedExpense.participants.length;
    final paidParticipants =
        sharedExpense.participants.where((p) => p.isSettled).length;
    final isFullySettled = paidParticipants == totalParticipants;

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
                    sharedExpense.description,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      _handleSharedExpenseAction(value, sharedExpense),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'view', child: Text('Lihat Detail')),
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
                  'Rp ${sharedExpense.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isFullySettled
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isFullySettled ? 'Lunas' : 'Belum Lunas',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isFullySettled ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$paidParticipants/$totalParticipants peserta sudah membayar',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: totalParticipants > 0
                  ? paidParticipants / totalParticipants
                  : 0.0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isFullySettled ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSharedExpenseAction(String action, SharedExpense sharedExpense) {
    switch (action) {
      case 'view':
        _showSharedExpenseDetails(sharedExpense);
        break;
      case 'edit':
        _showEditSharedExpenseDialog(sharedExpense);
        break;
      case 'delete':
        _showDeleteConfirmation(sharedExpense);
        break;
    }
  }

  void _showSharedExpenseDetails(SharedExpense sharedExpense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(sharedExpense.description),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: Rp ${sharedExpense.totalAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            const Text('Peserta:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...sharedExpense.participants.map(
              (participant) => ListTile(
                leading: Icon(
                  participant.isSettled ? Icons.check_circle : Icons.pending,
                  color: participant.isSettled ? Colors.green : Colors.orange,
                ),
                title: Text(participant.displayName ?? participant.email),
                subtitle:
                    Text('Rp ${participant.amountPaid.toStringAsFixed(0)}'),
                trailing: participant.isSettled
                    ? const Text('Lunas',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold))
                    : const Text('Belum Lunas',
                        style: TextStyle(color: Colors.orange)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showAddSharedExpenseDialog() {
    _descriptionController.clear();
    _amountController.clear();
    _participantController.clear();
    _participants.clear();

    showDialog(
      context: context,
      builder: (context) => _buildSharedExpenseDialog(),
    );
  }

  void _showEditSharedExpenseDialog(SharedExpense sharedExpense) {
    _descriptionController.text = sharedExpense.description;
    _amountController.text = sharedExpense.totalAmount.toString();
    _participants = sharedExpense.participants
        .map((p) => p.displayName ?? p.email)
        .toList();

    showDialog(
      context: context,
      builder: (context) =>
          _buildSharedExpenseDialog(sharedExpense: sharedExpense),
    );
  }

  Widget _buildSharedExpenseDialog({SharedExpense? sharedExpense}) {
    return AlertDialog(
      title: Text(sharedExpense == null
          ? 'Buat Pengeluaran Bersama'
          : 'Edit Pengeluaran Bersama'),
      content: Form(
        key: _formKey,
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
                labelText: 'Total Jumlah',
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _participantController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Peserta',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (value) => _addParticipant(),
                  ),
                ),
                IconButton(
                  onPressed: _addParticipant,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_participants.isNotEmpty)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _participants.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_participants[index]),
                      trailing: IconButton(
                        onPressed: () => _removeParticipant(index),
                        icon: const Icon(Icons.remove),
                      ),
                    );
                  },
                ),
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
          onPressed: () => _saveSharedExpense(sharedExpense),
          child: Text(sharedExpense == null ? 'Buat' : 'Update'),
        ),
      ],
    );
  }

  void _addParticipant() {
    if (_participantController.text.isNotEmpty) {
      setState(() {
        _participants.add(_participantController.text);
        _participantController.clear();
      });
    }
  }

  void _removeParticipant(int index) {
    setState(() {
      _participants.removeAt(index);
    });
  }

  Future<void> _saveSharedExpense(SharedExpense? sharedExpense) async {
    if (_formKey.currentState!.validate() && _participants.isNotEmpty) {
      try {
        final user = ref.read(authNotifierProvider).user!;
        final repository = ref.read(sharedExpenseRepositoryProvider);

        final participants = _participants
            .map((name) => SharedExpenseParticipant(
                  userId: const Uuid().v4(),
                  email: name,
                  displayName: name,
                  amountOwed: double.parse(_amountController.text) /
                      _participants.length,
                  amountPaid: 0.0,
                  isSettled: false,
                ))
            .toList();

        final newSharedExpense = SharedExpense(
          id: sharedExpense?.id ?? const Uuid().v4(),
          title: _descriptionController.text,
          description: _descriptionController.text,
          totalAmount: double.parse(_amountController.text),
          participants: participants,
          items: [],
          createdBy: user.uid,
          createdAt: sharedExpense?.createdAt ?? DateTime.now(),
        );

        if (sharedExpense == null) {
          await repository.createSharedExpense(newSharedExpense);
        } else {
          await repository.updateSharedExpense(newSharedExpense);
        }

        Navigator.pop(context);
        _descriptionController.clear();
        _amountController.clear();
        _participants.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else if (_participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal harus ada 1 peserta')),
      );
    }
  }

  void _showDeleteConfirmation(SharedExpense sharedExpense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengeluaran Bersama'),
        content: Text(
            'Apakah Anda yakin ingin menghapus pengeluaran bersama "${sharedExpense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(sharedExpenseRepositoryProvider)
                    .deleteSharedExpense(sharedExpense.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Pengeluaran bersama berhasil dihapus')),
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
    _participantController.dispose();
    super.dispose();
  }
}
