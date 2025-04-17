class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String role; // 'Admin' hoặc 'User'

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'User', // Mặc định là 'User' nếu không có
      phone: json['phone'],
      address: json['address'],
    );
  }

  bool get isAdmin => role == 'Admin';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
    };
  }
}
