// lib/features/expense/presentation/pages/export_data_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../domain/entities/expense_entity.dart';
import '../../data/repository/expense_repository_impl.dart';
import '../../../category/data/repository/category_repository_impl.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../auth/presentation/riverpod/auth_provider.dart';
import '../../../../core/util/date_helper.dart';

class ExportDataPage extends ConsumerStatefulWidget {
  const ExportDataPage({super.key});

  @override
  ConsumerState<ExportDataPage> createState() => _ExportDataPageState();
}

class _ExportDataPageState extends ConsumerState<ExportDataPage> {
  DateTime _selectedStartDate = DateHelper.startOfMonth;
  DateTime _selectedEndDate = DateHelper.endOfMonth;
  List<Expense> _expenses = [];
  List<Category> _categories = [];
  bool _isLoading = false;

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

      setState(() {
        _expenses = expenses;
        _categories = categories;
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

  String _getCategoryName(String categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId).name;
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _exportToCSV() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<List<dynamic>> csvData = [
        ['Tanggal', 'Kategori', 'Deskripsi', 'Jumlah'],
      ];

      for (final expense in _expenses) {
        csvData.add([
          DateHelper.formatDate(expense.createdAt),
          _getCategoryName(expense.categoryId),
          expense.description,
          expense.amount,
        ]);
      }

      final csvString = const ListToCsvConverter().convert(csvData);

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'expenses_${DateHelper.formatDate(_selectedStartDate)}_to_${DateHelper.formatDate(_selectedEndDate)}.csv';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(csvString);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File CSV berhasil disimpan: $fileName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error export CSV: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportToPDF() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Laporan Pengeluaran',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Paragraph(
                text:
                    'Periode: ${DateHelper.formatDate(_selectedStartDate)} - ${DateHelper.formatDate(_selectedEndDate)}',
              ),
              pw.SizedBox(height: 20),

              // Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Ringkasan',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                        'Total Pengeluaran: ${DateHelper.formatCurrency(_expenses.fold(0.0, (sum, expense) => sum + expense.amount))}'),
                    pw.Text('Jumlah Transaksi: ${_expenses.length}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Expenses Table
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Tanggal',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Kategori',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Deskripsi',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Jumlah',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  for (final expense in _expenses)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text(DateHelper.formatDate(expense.createdAt)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(_getCategoryName(expense.categoryId)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(expense.description),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                              DateHelper.formatCurrency(expense.amount)),
                        ),
                      ],
                    ),
                ],
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'expenses_report.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF berhasil dibuat')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error export PDF: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            tooltip: 'Pilih Periode',
          ),
        ],
      ),
      body: Padding(
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
                      'Periode Export',
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
                      'Total Data: ${_expenses.length} transaksi',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Export Options
            const Text(
              'Pilih Format Export:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // CSV Export Button
            Card(
              child: ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Export ke CSV'),
                subtitle:
                    const Text('File spreadsheet yang bisa dibuka di Excel'),
                trailing: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                onTap: _isLoading ? null : _exportToCSV,
              ),
            ),
            const SizedBox(height: 8),

            // PDF Export Button
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Export ke PDF'),
                subtitle: const Text('Dokumen PDF dengan tabel dan grafik'),
                trailing: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                onTap: _isLoading ? null : _exportToPDF,
              ),
            ),
            const SizedBox(height: 24),

            // Preview Data
            if (_expenses.isNotEmpty) ...[
              const Text(
                'Preview Data:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Card(
                  child: ListView.builder(
                    itemCount: _expenses.length > 10 ? 10 : _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(int.parse(
                            _categories
                                .firstWhere(
                                  (cat) => cat.id == expense.categoryId,
                                  orElse: () => Category(
                                      id: '', name: '', colorHex: '#000000'),
                                )
                                .colorHex
                                .replaceFirst('#', '0xFF'),
                          )),
                          child: Text(
                            _getCategoryName(expense.categoryId)[0]
                                .toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(expense.description),
                        subtitle:
                            Text(DateHelper.formatDate(expense.createdAt)),
                        trailing: Text(
                          DateHelper.formatCurrency(expense.amount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
