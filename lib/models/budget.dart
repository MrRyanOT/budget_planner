class Budget {
  final String id;
  final String category;
  final double amount;
  final DateTime month;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.month,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'month': month.toIso8601String(),
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      month: DateTime.parse(json['month']),
    );
  }
}
