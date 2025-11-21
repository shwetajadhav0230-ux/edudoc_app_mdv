import 'dart:convert'; // ✅ IMPORT ADDED

class Transaction {
  final int id;
  final String type; // 'Credit', 'Debit', 'Download'
  final int amount;
  final String date;
  final String description;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
  });

  // ✅ ADDED: Convert to Map for saving
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'date': date,
      'description': description,
    };
  }

  // ✅ ADDED: Create from Map for loading
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? 0,
      type: map['type'] ?? '',
      amount: map['amount'] ?? 0,
      date: map['date'] ?? '',
      description: map['description'] ?? '',
    );
  }

  // Helper to encode to JSON string
  String toJson() => json.encode(toMap());

  // Helper to decode from JSON string
  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(json.decode(source));
}