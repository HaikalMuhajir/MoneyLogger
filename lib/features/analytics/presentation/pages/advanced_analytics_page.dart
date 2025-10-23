// lib/features/analytics/presentation/pages/advanced_analytics_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../../../core/util/date_helper.dart';
import '../../../../core/localization/app_localizations.dart';

class AdvancedAnalyticsPage extends ConsumerStatefulWidget {
  const AdvancedAnalyticsPage({super.key});

  @override
  ConsumerState<AdvancedAnalyticsPage> createState() =>
      _AdvancedAnalyticsPageState();
}

class _AdvancedAnalyticsPageState extends ConsumerState<AdvancedAnalyticsPage> {
  ExpenseAnalytics? _analytics;
  bool _isLoading = true;
  DateTime _selectedStartDate =
      DateTime.now().subtract(const Duration(days: 30));
  DateTime _selectedEndDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Implementation to load analytics data
      // This would typically involve:
      // 1. Loading expenses for the selected period
      // 2. Loading categories
      // 3. Calculating analytics metrics
      // 4. Generating insights

      setState(() {
        _analytics = _generateMockAnalytics();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }

  ExpenseAnalytics _generateMockAnalytics() {
    // Mock data for demonstration
    return ExpenseAnalytics(
      userId: 'mock_user',
      periodStart: _selectedStartDate,
      periodEnd: _selectedEndDate,
      totalExpenses: 2500000,
      averageDailyExpense: 83333,
      averageMonthlyExpense: 2500000,
      categoryBreakdown: [
        CategoryAnalytics(
          categoryId: '1',
          categoryName: 'Food & Dining',
          categoryColor: '#FF6B6B',
          totalAmount: 1000000,
          percentage: 40.0,
          transactionCount: 25,
          averageAmount: 40000,
          trend: ExpenseTrend.increasing,
        ),
        CategoryAnalytics(
          categoryId: '2',
          categoryName: 'Transportation',
          categoryColor: '#4ECDC4',
          totalAmount: 750000,
          percentage: 30.0,
          transactionCount: 15,
          averageAmount: 50000,
          trend: ExpenseTrend.stable,
        ),
        CategoryAnalytics(
          categoryId: '3',
          categoryName: 'Shopping',
          categoryColor: '#45B7D1',
          totalAmount: 500000,
          percentage: 20.0,
          transactionCount: 8,
          averageAmount: 62500,
          trend: ExpenseTrend.decreasing,
        ),
        CategoryAnalytics(
          categoryId: '4',
          categoryName: 'Entertainment',
          categoryColor: '#96CEB4',
          totalAmount: 250000,
          percentage: 10.0,
          transactionCount: 5,
          averageAmount: 50000,
          trend: ExpenseTrend.stable,
        ),
      ],
      dailyBreakdown: _generateMockDailyData(),
      monthlyBreakdown: _generateMockMonthlyData(),
      trends: ExpenseTrends(
        weeklyChange: 15.5,
        monthlyChange: -8.2,
        yearlyChange: 12.3,
        direction: TrendDirection.up,
        weeklyData: [50000, 75000, 60000, 80000, 90000, 70000, 85000],
        monthlyData: [2000000, 2200000, 1800000, 2500000, 2300000, 2100000],
      ),
      insights: [
        ExpenseInsight(
          id: '1',
          title: 'Spending Pattern Detected',
          description: 'You spend 40% more on weekends compared to weekdays',
          type: InsightType.spendingPattern,
          value: 40.0,
          generatedAt: DateTime.now(),
        ),
        ExpenseInsight(
          id: '2',
          title: 'Category Alert',
          description: 'Food & Dining expenses increased by 25% this month',
          type: InsightType.categoryAlert,
          value: 25.0,
          categoryId: '1',
          generatedAt: DateTime.now(),
        ),
        ExpenseInsight(
          id: '3',
          title: 'Saving Opportunity',
          description:
              'You could save Rp 200,000 by reducing transportation costs',
          type: InsightType.savingOpportunity,
          value: 200000,
          categoryId: '2',
          generatedAt: DateTime.now(),
        ),
      ],
    );
  }

  List<DailyAnalytics> _generateMockDailyData() {
    final List<DailyAnalytics> data = [];
    for (int i = 0; i < 30; i++) {
      final date = DateTime.now().subtract(Duration(days: 29 - i));
      data.add(DailyAnalytics(
        date: date,
        totalAmount: (50000 + (i * 2000) + (i % 7 == 0 ? 30000 : 0)).toDouble(),
        transactionCount: 2 + (i % 5),
        categories: ['Food', 'Transport'],
      ));
    }
    return data;
  }

  List<MonthlyAnalytics> _generateMockMonthlyData() {
    return [
      MonthlyAnalytics(
        year: 2024,
        month: 1,
        totalAmount: 2000000,
        transactionCount: 45,
        averageDailyAmount: 64516,
        topCategories: ['Food', 'Transport', 'Shopping'],
      ),
      MonthlyAnalytics(
        year: 2024,
        month: 2,
        totalAmount: 2200000,
        transactionCount: 52,
        averageDailyAmount: 78571,
        topCategories: ['Food', 'Transport', 'Entertainment'],
      ),
      MonthlyAnalytics(
        year: 2024,
        month: 3,
        totalAmount: 1800000,
        transactionCount: 38,
        averageDailyAmount: 58065,
        topCategories: ['Food', 'Shopping', 'Transport'],
      ),
    ];
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange:
          DateTimeRange(start: _selectedStartDate, end: _selectedEndDate),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      _loadAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analytics),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analytics == null
              ? const Center(child: Text('No analytics data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period Info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Analytics Period',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${DateHelper.formatDate(_selectedStartDate)} - ${DateHelper.formatDate(_selectedEndDate)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Total Expenses',
                                    DateHelper.formatCurrency(
                                        _analytics!.totalExpenses),
                                    Icons.account_balance_wallet,
                                    Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    'Daily Average',
                                    DateHelper.formatCurrency(
                                        _analytics!.averageDailyExpense),
                                    Icons.trending_up,
                                    Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Category Breakdown Chart
                      const Text(
                        'Expense Breakdown by Category',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: PieChart(
                          PieChartData(
                            sections:
                                _analytics!.categoryBreakdown.map((category) {
                              return PieChartSectionData(
                                color: Color(int.parse(category.categoryColor
                                    .replaceFirst('#', '0xFF'))),
                                value: category.totalAmount,
                                title:
                                    '${category.percentage.toStringAsFixed(1)}%',
                                radius: 80,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Category Details
                      const Text(
                        'Category Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ..._analytics!.categoryBreakdown
                          .map((category) => _buildCategoryCard(category)),

                      const SizedBox(height: 24),

                      // Trends Chart
                      const Text(
                        'Spending Trends',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: const FlTitlesData(show: true),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _analytics!.trends.weeklyData
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  return FlSpot(
                                      entry.key.toDouble(), entry.value);
                                }).toList(),
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Insights
                      const Text(
                        'Insights & Recommendations',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ..._analytics!.insights
                          .map((insight) => _buildInsightCard(insight)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(CategoryAnalytics category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Color(
                int.parse(category.categoryColor.replaceFirst('#', '0xFF'))),
            shape: BoxShape.circle,
          ),
        ),
        title: Text(category.categoryName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${category.transactionCount} transactions'),
            LinearProgressIndicator(
              value: category.percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(int.parse(
                    category.categoryColor.replaceFirst('#', '0xFF'))),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateHelper.formatCurrency(category.totalAmount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${category.percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(ExpenseInsight insight) {
    IconData icon;
    Color color;

    switch (insight.type) {
      case InsightType.spendingPattern:
        icon = Icons.trending_up;
        color = Colors.blue;
        break;
      case InsightType.categoryAlert:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case InsightType.savingOpportunity:
        icon = Icons.savings;
        color = Colors.green;
        break;
      case InsightType.budgetWarning:
        icon = Icons.account_balance_wallet;
        color = Colors.red;
        break;
      case InsightType.unusualSpending:
        icon = Icons.analytics;
        color = Colors.purple;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(insight.title),
        subtitle: Text(insight.description),
        trailing: insight.value != null
            ? Text(
                insight.value! > 1000
                    ? DateHelper.formatCurrency(insight.value!)
                    : '${insight.value!.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              )
            : null,
      ),
    );
  }
}
