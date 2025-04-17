import 'package:frontend/models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(), // ✅ sửa lại dòng này
      'quantity': quantity,
    };
  }

  double get totalPrice => product.price * quantity;
}

class Cart {
  final List<CartItem> items;

  Cart({this.items = const []});

  factory Cart.fromJson(Map<String, dynamic> json) {
    List<CartItem> parsedItems = [];

    if (json['items'] != null && json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList();
    }

    return Cart(items: parsedItems);
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem(Product product) {
    final index = items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      items[index].quantity++;
    } else {
      items.add(CartItem(product: product));
    }
  }

  void removeItem(Product product) {
    final index = items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (items[index].quantity > 1) {
        items[index].quantity--;
      } else {
        items.removeAt(index);
      }
    }
  }

  void clear() {
    items.clear();
  }
}
