class Category {
  final int id;
  final String name;
  final String slug;
  final String? image;
  final int? order;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.order,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'] ?? json['slugd'] ?? '', // Xử lý cả slug và slugd
      image: json['image'],
      order: json['order'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
