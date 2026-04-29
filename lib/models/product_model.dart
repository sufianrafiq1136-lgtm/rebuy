class Product {
  final String id;
  final String name;
  final String category;
  final int price;
  final double rating;
  final String image;
  final String sellerId;
  final DateTime createdAt;
  final String? description;
  final bool isFavorite;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.image,
    required this.sellerId,
    required this.createdAt,
    this.description,
    this.isFavorite = false,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    int? price,
    double? rating,
    String? image,
    String? sellerId,
    DateTime? createdAt,
    String? description,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      image: image ?? this.image,
      sellerId: sellerId ?? this.sellerId,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
