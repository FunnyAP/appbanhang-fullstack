part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class SubmitOrder extends OrderEvent {
  final Cart cart;

  const SubmitOrder(this.cart);

  @override
  List<Object?> get props => [cart];
}
