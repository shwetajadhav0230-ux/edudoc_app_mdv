// lib/models/review.dart
class Review {
  final int id;
  final String userId;
  final int productId;
  final String? userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.productId,
    this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      userId: map['user_id'],
      userName: map['user_name'],
      productId: map['product_id'],
      rating: (map['rating'] is int)
          ? (map['rating'] as int).toDouble()
          : (map['rating'] as double),
      comment: map['comment'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}