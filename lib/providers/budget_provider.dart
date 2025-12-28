import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';
import '../models/budget.dart';

class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

class BudgetProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  final Map<String, double> _monthlyIncomes = {};
  final Map<String, double> _monthlyDebitOrders = {};
  late SharedPreferences _prefs;
  String _selectedCurrency = 'USD';

  static const Map<String, CurrencyInfo> currencies = {
    'USD': CurrencyInfo(code: 'USD', name: 'US Dollar', symbol: '\$'),
    'EUR': CurrencyInfo(code: 'EUR', name: 'Euro', symbol: '€'),
    'GBP': CurrencyInfo(code: 'GBP', name: 'British Pound', symbol: '£'),
    'JPY': CurrencyInfo(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
    'AUD': CurrencyInfo(code: 'AUD', name: 'Australian Dollar', symbol: '\$'),
    'CAD': CurrencyInfo(code: 'CAD', name: 'Canadian Dollar', symbol: '\$'),
    'CHF': CurrencyInfo(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF'),
    'CNY': CurrencyInfo(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
    'INR': CurrencyInfo(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
    'MXN': CurrencyInfo(code: 'MXN', name: 'Mexican Peso', symbol: '\$'),
    'SGD': CurrencyInfo(code: 'SGD', name: 'Singapore Dollar', symbol: '\$'),
    'HKD': CurrencyInfo(code: 'HKD', name: 'Hong Kong Dollar', symbol: '\$'),
    'NZD': CurrencyInfo(code: 'NZD', name: 'New Zealand Dollar', symbol: '\$'),
    'ZAR': CurrencyInfo(code: 'ZAR', name: 'South African Rand', symbol: 'R'),
    'BRL': CurrencyInfo(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$'),
    'KRW': CurrencyInfo(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
  };

  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  String get selectedCurrency => _selectedCurrency;
  String get currencySymbol => currencies[_selectedCurrency]?.symbol ?? '\$';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCurrency();
    _loadTransactions();
    _loadBudgets();
    _loadMonthlyIncomes();
    _loadMonthlyDebitOrders();
    await _migrateShoppingToClothing();
  }

  void _loadCurrency() {
    final saved = _prefs.getString('selectedCurrency');
    if (saved != null && currencies.containsKey(saved)) {
      _selectedCurrency = saved;
    }
  }

  void setCurrency(String currencyCode) {
    if (currencies.containsKey(currencyCode)) {
      _selectedCurrency = currencyCode;
      _prefs.setString('selectedCurrency', currencyCode);
      notifyListeners();
    }
  }

  void _loadTransactions() {
    final data = _prefs.getString('transactions');
    if (data != null) {
      final List<dynamic> decoded = json.decode(data);
      _transactions = decoded
          .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  void _loadBudgets() {
    final data = _prefs.getString('budgets');
    if (data != null) {
      final List<dynamic> decoded = json.decode(data);
      _budgets = decoded
          .map((item) => Budget.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  void _loadMonthlyIncomes() {
    final data = _prefs.getString('monthlyIncomes');
    if (data != null) {
      final Map<String, dynamic> decoded = json.decode(data);
      _monthlyIncomes.clear();
      decoded.forEach((key, value) {
        final v = (value is num) ? value.toDouble() : double.tryParse('$value');
        if (v != null) {
          _monthlyIncomes[key] = v;
        }
      });
    }
  }

  void _loadMonthlyDebitOrders() {
    final data = _prefs.getString('monthlyDebitOrders');
    if (data != null) {
      final Map<String, dynamic> decoded = json.decode(data);
      _monthlyDebitOrders.clear();
      decoded.forEach((key, value) {
        final v = (value is num) ? value.toDouble() : double.tryParse('$value');
        if (v != null) {
          _monthlyDebitOrders[key] = v;
        }
      });
    }
  }

  void _saveTransactions() {
    _prefs.setString(
      'transactions',
      json.encode(_transactions.map((t) => t.toJson()).toList()),
    );
  }

  void _saveBudgets() {
    _prefs.setString(
      'budgets',
      json.encode(_budgets.map((b) => b.toJson()).toList()),
    );
  }

  void _saveMonthlyIncomes() {
    _prefs.setString(
      'monthlyIncomes',
      json.encode(_monthlyIncomes),
    );
  }

  void _saveMonthlyDebitOrders() {
    _prefs.setString(
      'monthlyDebitOrders',
      json.encode(_monthlyDebitOrders),
    );
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    _saveTransactions();
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _saveTransactions();
    notifyListeners();
  }

  void addBudget(Budget budget) {
    _budgets.add(budget);
    _saveBudgets();
    notifyListeners();
  }

  void deleteBudget(String id) {
    _budgets.removeWhere((b) => b.id == id);
    _saveBudgets();
    notifyListeners();
  }

  double getTotalIncome() {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getTotalExpenses() {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getBalance() {
    return getTotalIncome() - getTotalExpenses();
  }

  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  List<Transaction> getTransactionsByMonth(DateTime month) {
    return _transactions
        .where((t) =>
            t.date.year == month.year && t.date.month == month.month)
        .toList();
  }

  Budget? getBudgetForCategory(String category, DateTime month) {
    try {
      return _budgets.firstWhere(
        (b) =>
            b.category == category &&
            b.month.year == month.year &&
            b.month.month == month.month,
      );
    } catch (e) {
      return null;
    }
  }

  double getTotalSpentForCategory(String category, DateTime month) {
    return _transactions
        .where((t) =>
            t.category == category &&
            t.type == TransactionType.expense &&
            t.date.year == month.year &&
            t.date.month == month.month)
        .fold(0, (sum, t) => sum + t.amount);
  }

  void updateBudget({
    required String id,
    required String category,
    required double amount,
    required DateTime month,
  }) {
    final index = _budgets.indexWhere((b) => b.id == id);
    if (index != -1) {
      _budgets[index] = Budget(
        id: id,
        category: category,
        amount: amount,
        month: month,
      );
      _saveBudgets();
      notifyListeners();
    }
  }

  List<Budget> getBudgetsForMonth(DateTime month) {
    return _budgets
        .where((b) => b.month.year == month.year && b.month.month == month.month)
        .toList();
  }

  // Monthly income helpers
  String _monthKey(DateTime month) =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}';

  double getMonthlyIncome(DateTime month) {
    return _monthlyIncomes[_monthKey(month)] ?? 0.0;
  }

  void setMonthlyIncome(DateTime month, double amount) {
    _monthlyIncomes[_monthKey(month)] = amount;
    _saveMonthlyIncomes();
    notifyListeners();
  }

  double getMonthlyDebitOrders(DateTime month) {
    return _monthlyDebitOrders[_monthKey(month)] ?? 0.0;
  }

  void setMonthlyDebitOrders(DateTime month, double amount) {
    _monthlyDebitOrders[_monthKey(month)] = amount;
    _saveMonthlyDebitOrders();
    notifyListeners();
  }

  // One-time migration: rename 'Shopping' to 'Clothing' in stored data
  Future<void> _migrateShoppingToClothing() async {
    final migrated = _prefs.getBool('migrated_shopping_to_clothing') ?? false;
    if (migrated) return;

    bool changed = false;

    for (int i = 0; i < _transactions.length; i++) {
      final t = _transactions[i];
      if (t.category == 'Shopping') {
        _transactions[i] = Transaction(
          id: t.id,
          title: t.title,
          amount: t.amount,
          type: t.type,
          category: 'Clothing',
          date: t.date,
          description: t.description,
        );
        changed = true;
      }
    }

    for (int i = 0; i < _budgets.length; i++) {
      final b = _budgets[i];
      if (b.category == 'Shopping') {
        _budgets[i] = Budget(
          id: b.id,
          category: 'Clothing',
          amount: b.amount,
          month: b.month,
        );
        changed = true;
      }
    }

    if (changed) {
      _saveTransactions();
      _saveBudgets();
    }

    await _prefs.setBool('migrated_shopping_to_clothing', true);
  }
}
