import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/models/cart.dart';
import 'package:frontend/repositories/order_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc(this.orderRepository) : super(OrderInitial()) {
    on<SubmitOrder>(_onSubmitOrder);
  }

  Future<void> _onSubmitOrder(
      SubmitOrder event, Emitter<OrderState> emit) async {
    emit(OrderSubmitting());
    try {
      await orderRepository.createOrder(event.cart);
      emit(OrderSuccess());
    } catch (e) {
      emit(OrderFailure(e.toString()));
    }
  }
}
