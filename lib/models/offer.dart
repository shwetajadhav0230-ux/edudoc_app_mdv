// lib/models/offer.dart

class Offer {
  final int id;
  final String title;
  final String description; // ✅ Added
  final String discount;
  final String duration;
  final String status;
  final String imageUrl;    // ✅ Added
  final List<int> productIds;
  final int tokenPrice;

  Offer({
    required this.id,
    required this.title,
    required this.description, // ✅ Added
    required this.discount,
    required this.duration,
    required this.status,
    required this.imageUrl,    // ✅ Added
    required this.productIds,
    required this.tokenPrice,
  });

  // Factory to create an Offer from Supabase JSON
  factory Offer.fromMap(Map<String, dynamic> map) {
    return Offer(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '', // ✅ Map from DB
      discount: map['discount'] ?? '',
      duration: map['duration'] ?? '',
      status: map['status'] ?? 'Inactive',
      imageUrl: map['image_url'] ?? '',      // ✅ Map from DB (snake_case)
      // Handle Supabase array (which might be List<dynamic>)
      productIds: map['product_ids'] != null
          ? List<int>.from(map['product_ids'])
          : [],
      tokenPrice: map['token_price'] ?? 0,
    );
  }
}