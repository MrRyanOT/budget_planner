import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/budget_provider.dart';
import '../models/budget.dart';

class BudgetAllocationScreen extends StatefulWidget {
  const BudgetAllocationScreen({Key? key}) : super(key: key);

  @override
  State<BudgetAllocationScreen> createState() => _BudgetAllocationScreenState();
}

class _BudgetAllocationScreenState extends State<BudgetAllocationScreen> {
  late DateTime _selectedMonth;
  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _debitOrdersController = TextEditingController();

  final List<String> expenseCategories = [
    'Savings',
    'Food',
    'Transportation',
    'Entertainment',
    'Clothing',
    'Utilities',
    'Health',
    'Maintenance',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _initializeControllers();
  }

  void _initializeControllers() {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final monthlyIncome = budgetProvider.getMonthlyIncome(_selectedMonth);
    _incomeController.text = monthlyIncome > 0
        ? monthlyIncome.toStringAsFixed(2)
        : '';
    final monthlyDebitOrders = budgetProvider.getMonthlyDebitOrders(_selectedMonth);
    _debitOrdersController.text = monthlyDebitOrders > 0
        ? monthlyDebitOrders.toStringAsFixed(2)
        : '';
    for (var category in expenseCategories) {
      final budget = budgetProvider.getBudgetForCategory(category, _selectedMonth);
      _controllers[category] = TextEditingController(
        text: budget != null ? budget.amount.toStringAsFixed(2) : '',
      );
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _debitOrdersController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveBudgets() {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    // Save income for this month if provided
    final incomeText = _incomeController.text.trim();
    if (incomeText.isNotEmpty) {
      final income = double.tryParse(incomeText) ?? 0;
      if (income > 0) {
        budgetProvider.setMonthlyIncome(_selectedMonth, income);
      }
    }
    // Save debit orders for this month if provided
    final debitOrdersText = _debitOrdersController.text.trim();
    if (debitOrdersText.isNotEmpty) {
      final debitOrders = double.tryParse(debitOrdersText) ?? 0;
      budgetProvider.setMonthlyDebitOrders(_selectedMonth, debitOrders);
    }
    
    for (var category in expenseCategories) {
      final amount = _controllers[category]?.text;
      if (amount != null && amount.isNotEmpty) {
        final parsedAmount = double.tryParse(amount) ?? 0;
        if (parsedAmount > 0) {
          final existingBudget = budgetProvider.getBudgetForCategory(category, _selectedMonth);
          if (existingBudget != null) {
            budgetProvider.updateBudget(
              id: existingBudget.id,
              category: category,
              amount: parsedAmount,
              month: _selectedMonth,
            );
          } else {
            budgetProvider.addBudget(
              Budget(
                id: const Uuid().v4(),
                category: category,
                amount: parsedAmount,
                month: _selectedMonth,
              ),
            );
          }
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budgets saved successfully')),
    );
  }

  void _estimateFromIncome() {
    final text = _incomeController.text.trim();
    final income = double.tryParse(text) ?? 0;
    if (income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid monthly income first')),
      );
      return;
    }

    // Subtract debit orders from income
    final debitOrdersText = _debitOrdersController.text.trim();
    final debitOrders = double.tryParse(debitOrdersText) ?? 0;
    final availableIncome = income - debitOrders;

    if (availableIncome <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debit orders exceed income. No funds available for budgeting.')),
      );
      return;
    }

    // Simple default allocation (approx 50/30/20 with finer granularity)
    final Map<String, double> pct = {
      'Savings': 0.20,
      'Food': 0.15,
      'Transportation': 0.10,
      'Utilities': 0.10,
      'Health': 0.05,
      'Entertainment': 0.08,
      'Clothing': 0.07,
      'Maintenance': 0.05,
      'Other': 0.05,
    };

    setState(() {
      for (final cat in expenseCategories) {
        final p = pct[cat] ?? 0.0;
        final value = (availableIncome * p);
        _controllers[cat]?.text = value > 0 ? value.toStringAsFixed(2) : '';
      }
    });
  }

  void _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (DateTime date) {
        return date.day == 1;
      },
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
        _controllers.clear();
        _initializeControllers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Budget Allocation'),
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Monthly Income
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Income',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _incomeController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixText: budgetProvider.currencySymbol,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Monthly Debit Orders',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _debitOrdersController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixText: budgetProvider.currencySymbol,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: 'Fixed monthly payments',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _estimateFromIncome,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Estimate Budget'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Month Selector
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: _selectMonth,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Month: ${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
                // Budget Inputs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: expenseCategories.map((category) {
                      final spent = budgetProvider.getTotalSpentForCategory(
                        category,
                        _selectedMonth,
                      );
                      final budget = budgetProvider.getBudgetForCategory(
                        category,
                        _selectedMonth,
                      );
                      final budgetAmount = budget?.amount ?? 0;
                      final percentage = budgetAmount > 0
                          ? (spent / budgetAmount * 100).clamp(0, 100)
                          : 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controllers[category],
                                  decoration: InputDecoration(
                                    labelText: 'Budget Amount',
                                    prefixText: '${budgetProvider.currencySymbol}',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          if (budgetAmount > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Spent: ${budgetProvider.currencySymbol}${spent.toStringAsFixed(2)} / ${budgetProvider.currencySymbol}${budgetAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        '${percentage.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: percentage > 100
                                              ? Colors.red
                                              : percentage > 80
                                                  ? Colors.orange
                                                  : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: (percentage / 100).clamp(0, 1),
                                      minHeight: 6,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        percentage > 100
                                            ? Colors.red
                                            : percentage > 80
                                                ? Colors.orange
                                                : Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                // Save Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveBudgets,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Monthly Budget'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
