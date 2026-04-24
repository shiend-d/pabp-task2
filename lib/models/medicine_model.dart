class Medicine {
  final int id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final bool requiresPrescription;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Medicine({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.requiresPrescription,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'Umum',
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int? ?? 0,
      requiresPrescription: json['requires_prescription'] as bool? ?? false,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'requires_prescription': requiresPrescription,
      'description': description,
    };
  }

  bool get isLowStock => stock < 10;
  bool get isOutOfStock => stock <= 0;
}
