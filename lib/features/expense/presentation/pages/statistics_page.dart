// lib/features/expense/presentation/pages/statistics_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/expense_entity.dart';
import '../../data/repository/expense_repository_impl.dart';
import '../../../category/data/repository/category_repository_impl.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../auth/presentation/riverpod/auth_provider.dart';
import '../../../../core/util/date_helper.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  DateTime _selectedStartDate = DateHelper.startOfMonth;
  DateTime _selectedEndDate = DateHelper.endOfMonth;
  List<Expense> _expenses = [];
  List<Category> _categories = [];
  double _totalExpenses = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      final expenseRepository = ref.read(expenseRepositoryProvider);
      final categoryRepository = ref.read(categoryRepositoryProvider);

      final expenses = await expenseRepository
          .getExpensesByDateRange(
              user.uid, _selectedStartDate, _selectedEndDate)
          .first;
      final categories = await categoryRepository.getCategories(user.uid).first;
      final total = await expenseRepository.getTotalExpensesByDateRange(
          user.uid, _selectedStartDate, _selectedEndDate);

      setState(() {
        _expenses = expenses;
        _categories = categories;
        _totalExpenses = total;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _selectedStartDate,
        end: _selectedEndDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      _loadData();
    }
  }

  List<PieChartSectionData> _getPieChartData() {
    final Map<String, double> categoryTotals = {};

    for (final expense in _expenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    final List<PieChartSectionData> sections = [];
    categoryTotals.forEach((categoryId, amount) {
      final category = _categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () =>
            Category(id: categoryId, name: 'Unknown', colorHex: '#000000'),
      );

      final percentage = (amount / _totalExpenses) * 100;

      sections.add(
        PieChartSectionData(
          color: Color(int.parse(category.colorHex.replaceFirst('#', '0xFF'))),
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    return sections;
  }

  List<BarChartGroupData> _getBarChartData() {
    final Map<String, double> dailyTotals = {};

    for (final expense in _expenses) {
      final dateKey = DateHelper.formatDate(expense.createdAt);
      dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + expense.amount;
    }

    final List<BarChartGroupData> groups = [];
    int index = 0;

    dailyTotals.forEach((date, amount) {
      groups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: amount,
              color: Colors.blue,
              width: 16,
            ),
          ],
        ),
      );
      index++;
    });

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Pengeluaran'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            tooltip: 'Pilih Periode',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Range Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Periode',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${DateHelper.formatDate(_selectedStartDate)} - ${DateHelper.formatDate(_selectedEndDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Pengeluaran: ${DateHelper.formatCurrency(_totalExpenses)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pie Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Pengeluaran per Kategori',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: _expenses.isEmpty
                          ? const Center(child: Text('Tidak ada data'))
                          : PieChart(
                              PieChartData(
                                sections: _getPieChartData(),
                                centerSpaceRadius: 40,
                                sectionsSpace: 2,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bar Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Pengeluaran Harian',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: _expenses.isEmpty
                          ? const Center(child: Text('Tidak ada data'))
                          : BarChart(
                              BarChartData(
                                barGroups: _getBarChartData(),
                                titlesData: const FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rincian per Kategori',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    for (final category in _categories) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Color(int.parse(category.colorHex
                                    .replaceFirst('#', '0xFF'))),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(category.name)),
                            Text(
                              DateHelper.formatCurrency(_expenses
                                  .where((expense) =>
                                      expense.categoryId == category.id)
                                  .fold(0.0,
                                      (sum, expense) => sum + expense.amount)),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_totalExpenses > 0 ? (_expenses.where((expense) => expense.categoryId == category.id).fold(0.0, (sum, expense) => sum + expense.amount) / _totalExpenses) * 100 : 0.0}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
