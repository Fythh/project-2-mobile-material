class MaterialModel {
  final int? id;
  final String name;
  final String category;
  final int price;
  final int stock;
  final String description;
  final double? rating;
  final String? imageUrl;  // ← TAMBAHKAN INI

  MaterialModel({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.description,
    this.rating,
    this.imageUrl,  // ← TAMBAHKAN INI
  });

  // ============ CONVERT FROM JSON (buat nerima data dari API) ============
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: json['price'] ?? 0,
      stock: json['stock'] ?? 0,
      description: json['description'] ?? '',
      rating: json['rating']?.toDouble() ?? 0.0,
      imageUrl: json['image_url'],  // ← TAMBAHKAN INI
    );
  }

  // ============ CONVERT TO JSON (buat kirim data ke API) ============
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'description': description,
      'rating': rating ?? 0,
      'image_url': imageUrl,  // ← TAMBAHKAN INI
    };
  }

  // ============ COPY WITH (buat edit data) ============
  MaterialModel copyWith({
    int? id,
    String? name,
    String? category,
    int? price,
    int? stock,
    String? description,
    double? rating,
    String? imageUrl,  // ← TAMBAHKAN INI
  }) {
    return MaterialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,  // ← TAMBAHKAN INI
    );
  }
}