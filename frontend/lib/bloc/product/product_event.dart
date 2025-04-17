part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductEvent {
  final String? query;

  const LoadProducts({this.query});

  @override
  List<Object> get props => [query ?? ''];
}

class LoadMoreProducts extends ProductEvent {
  const LoadMoreProducts();
}

class CreateProduct extends ProductEvent {
  final Map<String, dynamic> productData;

  const CreateProduct(this.productData);

  @override
  List<Object> get props => [productData];
}

class UpdateProduct extends ProductEvent {
  final int productId;
  final Map<String, dynamic> updateData;

  const UpdateProduct(this.productId, this.updateData);

  @override
  List<Object> get props => [productId, updateData];
}

class DeleteProduct extends ProductEvent {
  final int productId;

  const DeleteProduct(this.productId);

  @override
  List<Object> get props => [productId];
}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object> get props => [query];
}

class RefreshProducts extends ProductEvent {
  const RefreshProducts();
}

class FilterProductsByCategory extends ProductEvent {
  final int categoryId;

  const FilterProductsByCategory({required this.categoryId});

  @override
  List<Object> get props => [categoryId];
}
