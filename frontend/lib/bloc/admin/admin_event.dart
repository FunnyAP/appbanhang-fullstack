part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();
}

// ---------------- SẢN PHẨM ----------------
class LoadProductsEvent extends AdminEvent {
  @override
  List<Object> get props => [];
}

class DeleteProductEvent extends AdminEvent {
  final int productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object> get props => [productId];
}

class UpdateProductEvent extends AdminEvent {
  final int productId;
  final Map<String, dynamic> updateData;

  const UpdateProductEvent(this.productId, this.updateData);

  @override
  List<Object> get props => [productId, updateData];
}

class AddProductEvent extends AdminEvent {
  final Map<String, dynamic> productData;

  const AddProductEvent(this.productData);

  @override
  List<Object> get props => [productData];
}

class ToggleProductStatusEvent extends AdminEvent {
  final int productId;
  final int newStatus; // ✅ tinyint: 1 = hiển thị, 0 = ẩn

  const ToggleProductStatusEvent(this.productId, this.newStatus);

  @override
  List<Object> get props => [productId, newStatus];
}

// ---------------- DANH MỤC ----------------
class LoadCategoriesEvent extends AdminEvent {
  @override
  List<Object> get props => [];
}

class AddCategoryEvent extends AdminEvent {
  final String name;
  final int status; // ✅ tinyint

  const AddCategoryEvent(this.name, this.status);

  @override
  List<Object> get props => [name, status];
}

class UpdateCategoryEvent extends AdminEvent {
  final int categoryId;
  final String name;
  final int status; // ✅ tinyint

  const UpdateCategoryEvent(this.categoryId, this.name, this.status);

  @override
  List<Object> get props => [categoryId, name, status];
}

class DeleteCategoryEvent extends AdminEvent {
  final int categoryId;

  const DeleteCategoryEvent(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}
