import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Common
  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get add => _localizedValues[locale.languageCode]!['add']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;

  // Authentication
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get register => _localizedValues[locale.languageCode]!['register']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get confirmPassword =>
      _localizedValues[locale.languageCode]!['confirmPassword']!;

  // Expenses
  String get expenses => _localizedValues[locale.languageCode]!['expenses']!;
  String get addExpense =>
      _localizedValues[locale.languageCode]!['addExpense']!;
  String get editExpense =>
      _localizedValues[locale.languageCode]!['editExpense']!;
  String get amount => _localizedValues[locale.languageCode]!['amount']!;
  String get description =>
      _localizedValues[locale.languageCode]!['description']!;
  String get category => _localizedValues[locale.languageCode]!['category']!;
  String get date => _localizedValues[locale.languageCode]!['date']!;
  String get totalExpenses =>
      _localizedValues[locale.languageCode]!['totalExpenses']!;

  // Categories
  String get categories =>
      _localizedValues[locale.languageCode]!['categories']!;
  String get addCategory =>
      _localizedValues[locale.languageCode]!['addCategory']!;
  String get categoryName =>
      _localizedValues[locale.languageCode]!['categoryName']!;
  String get categoryColor =>
      _localizedValues[locale.languageCode]!['categoryColor']!;

  // Statistics
  String get statistics =>
      _localizedValues[locale.languageCode]!['statistics']!;
  String get analytics => _localizedValues[locale.languageCode]!['analytics']!;
  String get charts => _localizedValues[locale.languageCode]!['charts']!;
  String get reports => _localizedValues[locale.languageCode]!['reports']!;

  // Budget
  String get budget => _localizedValues[locale.languageCode]!['budget']!;
  String get budgets => _localizedValues[locale.languageCode]!['budgets']!;
  String get addBudget => _localizedValues[locale.languageCode]!['addBudget']!;
  String get budgetLimit =>
      _localizedValues[locale.languageCode]!['budgetLimit']!;
  String get spent => _localizedValues[locale.languageCode]!['spent']!;
  String get remaining => _localizedValues[locale.languageCode]!['remaining']!;

  // Recurring
  String get recurring => _localizedValues[locale.languageCode]!['recurring']!;
  String get recurringExpenses =>
      _localizedValues[locale.languageCode]!['recurringExpenses']!;
  String get frequency => _localizedValues[locale.languageCode]!['frequency']!;
  String get nextDue => _localizedValues[locale.languageCode]!['nextDue']!;

  // Shared Expenses
  String get sharedExpenses =>
      _localizedValues[locale.languageCode]!['sharedExpenses']!;
  String get splitExpense =>
      _localizedValues[locale.languageCode]!['splitExpense']!;
  String get participants =>
      _localizedValues[locale.languageCode]!['participants']!;
  String get settled => _localizedValues[locale.languageCode]!['settled']!;

  // Profile
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get displayName =>
      _localizedValues[locale.languageCode]!['displayName']!;

  // Export
  String get export => _localizedValues[locale.languageCode]!['export']!;
  String get exportData =>
      _localizedValues[locale.languageCode]!['exportData']!;
  String get exportToCSV =>
      _localizedValues[locale.languageCode]!['exportToCSV']!;
  String get exportToPDF =>
      _localizedValues[locale.languageCode]!['exportToPDF']!;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Money Logger',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'confirm': 'Confirm',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'expenses': 'Expenses',
      'addExpense': 'Add Expense',
      'editExpense': 'Edit Expense',
      'amount': 'Amount',
      'description': 'Description',
      'category': 'Category',
      'date': 'Date',
      'totalExpenses': 'Total Expenses',
      'categories': 'Categories',
      'addCategory': 'Add Category',
      'categoryName': 'Category Name',
      'categoryColor': 'Category Color',
      'statistics': 'Statistics',
      'analytics': 'Analytics',
      'charts': 'Charts',
      'reports': 'Reports',
      'budget': 'Budget',
      'budgets': 'Budgets',
      'addBudget': 'Add Budget',
      'budgetLimit': 'Budget Limit',
      'spent': 'Spent',
      'remaining': 'Remaining',
      'recurring': 'Recurring',
      'recurringExpenses': 'Recurring Expenses',
      'frequency': 'Frequency',
      'nextDue': 'Next Due',
      'sharedExpenses': 'Shared Expenses',
      'splitExpense': 'Split Expense',
      'participants': 'Participants',
      'settled': 'Settled',
      'profile': 'Profile',
      'settings': 'Settings',
      'displayName': 'Display Name',
      'export': 'Export',
      'exportData': 'Export Data',
      'exportToCSV': 'Export to CSV',
      'exportToPDF': 'Export to PDF',
    },
    'id': {
      'appTitle': 'Money Logger',
      'save': 'Simpan',
      'cancel': 'Batal',
      'delete': 'Hapus',
      'edit': 'Edit',
      'add': 'Tambah',
      'confirm': 'Konfirmasi',
      'loading': 'Memuat...',
      'error': 'Error',
      'success': 'Berhasil',
      'login': 'Masuk',
      'register': 'Daftar',
      'logout': 'Keluar',
      'email': 'Email',
      'password': 'Kata Sandi',
      'confirmPassword': 'Konfirmasi Kata Sandi',
      'expenses': 'Pengeluaran',
      'addExpense': 'Tambah Pengeluaran',
      'editExpense': 'Edit Pengeluaran',
      'amount': 'Jumlah',
      'description': 'Deskripsi',
      'category': 'Kategori',
      'date': 'Tanggal',
      'totalExpenses': 'Total Pengeluaran',
      'categories': 'Kategori',
      'addCategory': 'Tambah Kategori',
      'categoryName': 'Nama Kategori',
      'categoryColor': 'Warna Kategori',
      'statistics': 'Statistik',
      'analytics': 'Analitik',
      'charts': 'Grafik',
      'reports': 'Laporan',
      'budget': 'Anggaran',
      'budgets': 'Anggaran',
      'addBudget': 'Tambah Anggaran',
      'budgetLimit': 'Batas Anggaran',
      'spent': 'Terpakai',
      'remaining': 'Sisa',
      'recurring': 'Berulang',
      'recurringExpenses': 'Pengeluaran Berulang',
      'frequency': 'Frekuensi',
      'nextDue': 'Jatuh Tempo',
      'sharedExpenses': 'Pengeluaran Bersama',
      'splitExpense': 'Bagi Pengeluaran',
      'participants': 'Peserta',
      'settled': 'Lunas',
      'profile': 'Profil',
      'settings': 'Pengaturan',
      'displayName': 'Nama Tampilan',
      'export': 'Ekspor',
      'exportData': 'Ekspor Data',
      'exportToCSV': 'Ekspor ke CSV',
      'exportToPDF': 'Ekspor ke PDF',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'id'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
