// ... existing code ...

class Product {
  final int id;
  final String type;
  final String title;
  final String description;
  final int price;
  final bool isFree;
  final String category;
  final List<String> tags;
  final double rating;
  final String author;
  final int pages;
  final int reviewCount;
  final String details;
  final String content;
  final String? pdfUrl;
  final String imageUrl;

  Product({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.price,
    required this.isFree,
    required this.category,
    required this.tags,
    required this.rating,
    required this.author,
    required this.pages,
    required this.reviewCount,
    required this.details,
    required this.content,
    this.pdfUrl,
    required this.imageUrl,
  });

  // ✅ ADD THIS FACTORY CONSTRUCTOR
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      type: map['type'] ?? 'Document',
      title: map['title'] ?? 'Untitled',
      description: map['description'] ?? '',
      price: map['price'] is int ? map['price'] : int.tryParse(map['price'].toString()) ?? 0,
      isFree: map['is_free'] ?? false, // Note the snake_case mapping usually used in DBs
      category: map['category'] ?? 'General',
      // Handle tags stored as array or null
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      rating: (map['rating'] is int)
          ? (map['rating'] as int).toDouble()
          : (map['rating'] as double?) ?? 0.0,
      author: map['author'] ?? 'Unknown',
      pages: map['pages'] ?? 0,
      reviewCount: map['review_count'] ?? 0,
      details: map['details'] ?? '',
      content: map['content'] ?? '',
      // Ensure this maps to your Supabase column for the PDF link
      pdfUrl: map['pdf_url'],
      imageUrl: map['cover_image_url'] ?? map['image_url'] ?? '',
    );
  }
}