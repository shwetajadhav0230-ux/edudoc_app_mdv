// lib/models/offer.dart

class Offer {
  final int id;
  final String title;
  final String? coverImageUrl; // ✅ Matches SQL cover_image_url
  final String? discountLabel; // ✅ Matches SQL discount_label
  final int tokenPrice;
  final String? duration;
  final String status;
  final String? discount;      // ✅ Matches SQL discount (text)
  final List<int> productIds;

  Offer({
    required this.id,
    required this.title,
    this.coverImageUrl,
    this.discountLabel,
    required this.tokenPrice,
    this.duration,
    required this.status,
    this.discount,
    required this.productIds,
  });

  factory Offer.fromMap(Map<String, dynamic> map) {
    return Offer(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      // ✅ Map from your new SQL column
      coverImageUrl: map['cover_image_url'],
      discountLabel: map['discount_label'],
      tokenPrice: map['token_price'] ?? 0,
      duration: map['duration'],
      // Handle status enum as string or default to Active
      status: map['status']?.toString() ?? 'Active',
      discount: map['discount'],
      // Handle Supabase array
      productIds: map['product_ids'] != null
          ? List<int>.from(map['product_ids'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'cover_image_url': coverImageUrl,
      'discount_label': discountLabel,
      'token_price': tokenPrice,
      'duration': duration,
      'status': status,
      'discount': discount,
      'product_ids': productIds,
    };
  }
}