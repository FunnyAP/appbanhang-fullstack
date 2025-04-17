part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final Product product;

  const AddToCart(this.product);

  @override
  List<Object> get props => [product];
}

class RemoveFromCart extends CartEvent {
  final Product product;

  const RemoveFromCart(this.product);

  @override
  List<Object> get props => [product];
}

class UpdateCartItem extends CartEvent {
  final Product product;
  final int quantity;

  const UpdateCartItem({required this.product, required this.quantity});

  @override
  List<Object> get props => [product, quantity];
}

class ClearCart extends CartEvent {}
