# Budget Planner

A Flutter-based budget planning application to help users track their income and expenses effectively.

## Features

- **Transaction Management**: Add, view, and delete income and expense transactions
- **Budget Tracking**: Track your total income, expenses, and balance at a glance
- **Category Management**: Organize transactions by category (Food, Transportation, Entertainment, etc.)
- **Date Tracking**: Record transactions with specific dates
- **Persistent Storage**: All data is saved locally using SharedPreferences
- **Clean UI**: Material Design 3 interface with intuitive navigation

## Project Structure

```
lib/
├── main.dart                 # Entry point and main app structure
├── models/
│   ├── transaction.dart      # Transaction model
│   └── budget.dart          # Budget model
├── providers/
│   └── budget_provider.dart  # State management using Provider
├── screens/
│   ├── home_screen.dart      # Dashboard/home screen
│   ├── add_transaction_screen.dart  # Add new transaction
│   ├── transactions_screen.dart     # View all transactions
│   └── settings_screen.dart   # Settings
└── widgets/
    └── transaction_card.dart  # Reusable transaction card widget
```

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or later)
- Dart SDK

### Installation

1. Clone the repository:
```bash
cd budget_planner
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Dependencies

- **provider**: State management
- **intl**: Date and time formatting
- **shared_preferences**: Local data persistence
- **uuid**: Unique ID generation

## Usage

1. **Home Screen**: View your income, expenses, and balance summary
2. **Add Transaction**: Tap the floating action button to add a new transaction
3. **Transactions Screen**: View all transactions in a list
4. **Settings Screen**: Manage app preferences

## Features to Add

- Budget limits per category
- Charts and analytics
- Monthly reports
- Transaction search and filtering
- Recurring transactions
- Export data to CSV/PDF

## License

This project is open source and available under the MIT License.
