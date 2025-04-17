import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/models/cart.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/repositories/cart_repository.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc(this.cartRepository) : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartItem>(_onUpdateCartItem);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    try {
      final cart = await cartRepository.fetchCart();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError('Lỗi khi tải giỏ hàng: ${e.toString()}'));
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      final cart = await cartRepository.addToCart(product: event.product);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError('Lỗi khi thêm sản phẩm: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCartItem(
      UpdateCartItem event, Emitter<CartState> emit) async {
    try {
      final cart = await cartRepository.updateCartItem(
        product: event.product,
        quantity: event.quantity,
      );
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError('Lỗi khi cập nhật sản phẩm: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveFromCart(
      RemoveFromCart event, Emitter<CartState> emit) async {
    try {
      final cart = await cartRepository.removeFromCart(event.product);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError('Lỗi khi xóa sản phẩm: ${e.toString()}'));
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      await cartRepository.clearCart();
      emit(CartLoaded(Cart(items: [])));
    } catch (e) {
      emit(CartError('Lỗi khi xoá giỏ hàng: ${e.toString()}'));
    }
  }
}
