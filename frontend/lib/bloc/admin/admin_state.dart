part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  const AdminState();
}

class AdminInitial extends AdminState {
  @override
  List<Object> get props => [];
}

class AdminLoading extends AdminState {
  @override
  List<Object> get props => [];
}

class ProductsLoaded extends AdminState {
  final List<Product> products;

  const ProductsLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class CategoriesLoaded extends AdminState {
  final List<Category> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object> get props => [message];
}

class ProductOperationSuccess extends AdminState {
  final String message;

  const ProductOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
