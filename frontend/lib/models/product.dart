class Product {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final int stock;
  final String? image;
  final int categoryId;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    required this.stock,
    this.image,
    required this.categoryId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ✅ Getter sinh đường dẫn ảnh đầy đủ
  String get imageUrl {
    if (image == null || image!.isEmpty) {
      return '';
    }
    return 'http://127.0.0.1:8000/image-proxy/$image';
  }

  /// ✅ Factory để tạo từ JSON trả về từ API
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      image: json['image'] as String? ?? '',
      categoryId: json['category_id'] as int,
      status: json['status'] == true || json['status'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// ✅ Để dùng khi gửi dữ liệu lên server (POST, PUT)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'stock': stock,
      'image': image,
      'category_id': categoryId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// ✅ Format giá thành chuỗi có dấu chấm ngăn cách hàng nghìn
  String get formattedPrice {
    return '${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}đ';
  }
}
