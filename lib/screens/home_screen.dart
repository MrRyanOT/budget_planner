import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/transaction.dart';
import '../widgets/transaction_card.dart';
import 'budget_allocation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Income',
                            amount: budgetProvider.getTotalIncome(),
                            color: Colors.green,
                            currencySymbol: budgetProvider.currencySymbol,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Expenses',
                            amount: budgetProvider.getTotalExpenses(),
                            color: Colors.red,
                            currencySymbol: budgetProvider.currencySymbol,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(
                      title: 'Balance',
                      amount: budgetProvider.getBalance(),
                      color: budgetProvider.getBalance() >= 0
                          ? Colors.blue
                          : Colors.orange,
                      currencySymbol: budgetProvider.currencySymbol,
                    ),
                  ],
                ),
              ),
              // Budget Progress
              _buildBudgetProgress(context, budgetProvider),
              // Recent Transactions
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (budgetProvider.transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No transactions yet'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: budgetProvider.transactions.length > 5
                      ? 5
                      : budgetProvider.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = budgetProvider.transactions[index];
                    return TransactionCard(
                      transaction: transaction,
                      onDelete: () {
                        budgetProvider.deleteTransaction(transaction.id);
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required String currencySymbol,
  }) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$currencySymbol${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetProgress(
    BuildContext context,
    BudgetProvider budgetProvider,
  ) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final monthBudgets = budgetProvider.getBudgetsForMonth(currentMonth);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Budgets',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BudgetAllocationScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ],
          ),
          if (monthBudgets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'No budgets set for this month',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: monthBudgets.length,
              itemBuilder: (context, index) {
                final budget = monthBudgets[index];
                final spent = budgetProvider.getTotalSpentForCategory(
                  budget.category,
                  currentMonth,
                );
                final percentage = budget.amount > 0
                    ? (spent / budget.amount * 100).clamp(0, 100)
                    : 0;
                final isOverBudget = spent > budget.amount;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              budget.category,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isOverBudget
                                    ? Colors.red
                                    : percentage > 80
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (percentage / 100).clamp(0, 1),
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isOverBudget
                                  ? Colors.red
                                  : percentage > 80
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${budgetProvider.currencySymbol}${spent.toStringAsFixed(2)} / ${budgetProvider.currencySymbol}${budget.amount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (isOverBudget)
                          Text(
                            'Over budget by ${budgetProvider.currencySymbol}${(spent - budget.amount).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
