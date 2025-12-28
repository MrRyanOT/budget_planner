import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../widgets/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, _) {
        final transactions = budgetProvider.transactions;

        return Column(
          children: [
            // Filter Chips
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Income'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Expense'),
                  ],
                ),
              ),
            ),
            // Transactions List
            Expanded(
              child: transactions.isEmpty
                  ? const Center(
                      child: Text('No transactions found'),
                    )
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return TransactionCard(
                          transaction: transaction,
                          onDelete: () {
                            budgetProvider.deleteTransaction(transaction.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: _filter == label,
      onSelected: (selected) {
        setState(() {
          _filter = selected ? label : 'All';
        });
      },
    );
  }
}
