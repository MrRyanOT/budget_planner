import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, _) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: ListTile(
                  title: Text('App Settings'),
                  subtitle: Text('Manage your budget planner preferences'),
                ),
              ),
              ListTile(
                title: const Text('Currency'),
                subtitle: Text(BudgetProvider.currencies[budgetProvider.selectedCurrency]?.name ?? 'USD'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => _showCurrencyDialog(context, budgetProvider),
              ),
              ListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Enable notifications'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ),
              ListTile(
                title: const Text('Budget Alerts'),
                subtitle: const Text('Get alerts when over budget'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('About'),
                subtitle: const Text('Budget Planner v1.0.0'),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Help & Support'),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencyDialog(BuildContext context, BudgetProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: BudgetProvider.currencies.entries.map((entry) {
              final isSelected = entry.key == provider.selectedCurrency;
              return ListTile(
                title: Text('${entry.value.symbol} ${entry.value.code}'),
                subtitle: Text(entry.value.name),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                selected: isSelected,
                onTap: () {
                  provider.setCurrency(entry.key);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
