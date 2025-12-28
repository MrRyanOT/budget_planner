import 'package:uuid/uuid.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? description;

  Transaction({
    String? id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.toString(),
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      type: json['type'].contains('income')
          ? TransactionType.income
          : TransactionType.expense,
      category: json['category'],
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }
}
