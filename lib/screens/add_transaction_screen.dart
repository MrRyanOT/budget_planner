import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategory = 'Food';

  final List<String> expenseCategories = [
    'Savings',
    'Food',
    'Transportation',
    'Entertainment',
    'Shopping',
    'Utilities',
    'Health',
    'Other'
  ];

  final List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Bonus',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTransaction() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final transaction = Transaction(
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      type: _selectedType,
      category: _selectedCategory,
      date: _selectedDate,
      description: _descriptionController.text,
    );

    Provider.of<BudgetProvider>(context, listen: false)
        .addTransaction(transaction);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction added successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        _selectedType == TransactionType.income ? incomeCategories : expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type
              Text(
                'Transaction Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<TransactionType>(
                      segments: const <ButtonSegment<TransactionType>>[
                        ButtonSegment<TransactionType>(
                          value: TransactionType.income,
                          label: Text('Income'),
                        ),
                        ButtonSegment<TransactionType>(
                          value: TransactionType.expense,
                          label: Text('Expense'),
                        ),
                      ],
                      selected: <TransactionType>{_selectedType},
                      onSelectionChanged: (Set<TransactionType> newSelection) {
                        setState(() {
                          _selectedType = newSelection.first;
                          // Reset category to first item of new category list
                          final newCategories = _selectedType == TransactionType.income
                              ? incomeCategories
                              : expenseCategories;
                          _selectedCategory = newCategories.first;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Amount
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Category
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: categories
                    .map((cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value ?? categories.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Date
              Text(
                'Date',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Description
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Add Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
