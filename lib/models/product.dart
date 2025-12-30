class Product {
  final int id;
  final String type;
  final String title;
  final String description;
  final int price;
  final bool isFree;
  final bool isHardCopy;
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
    this.isHardCopy = false,
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

  // ADDED: copyWith method to handle immutable state updates
  Product copyWith({
    int? id,
    String? type,
    String? title,
    String? description,
    int? price,
    bool? isFree,
    bool? isHardCopy,
    String? category,
    List<String>? tags,
    double? rating,
    String? author,
    int? pages,
    int? reviewCount,
    String? details,
    String? content,
    String? pdfUrl,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
      isHardCopy: isHardCopy ?? this.isHardCopy,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      author: author ?? this.author,
      pages: pages ?? this.pages,
      reviewCount: reviewCount ?? this.reviewCount,
      details: details ?? this.details,
      content: content ?? this.content,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      type: map['type'] ?? 'Document',
      title: map['title'] ?? 'Untitled',
      description: map['description'] ?? '',
      price: map['price'] is int ? map['price'] : int.tryParse(map['price'].toString()) ?? 0,
      isFree: map['is_free'] ?? false,
      isHardCopy: map['is_hard_copy'] ?? false,
      category: map['category'] ?? 'General',
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      rating: (map['rating'] is int)
          ? (map['rating'] as int).toDouble()
          : (map['rating'] as double?) ?? 0.0,
      author: map['author'] ?? 'Unknown',
      pages: map['pages'] ?? 0,
      reviewCount: map['review_count'] ?? 0,
      details: map['details'] ?? '',
      content: map['content'] ?? '',
      pdfUrl: map['pdf_url'],
      imageUrl: map['cover_image_url'] ?? map['image_url'] ?? '',
    );
  }
}