part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends CategoryEvent {}

class AddCategory extends CategoryEvent {
  final String name;

  const AddCategory(this.name);

  @override
  List<Object> get props => [name];
}

class UpdateCategory extends CategoryEvent {
  final int categoryId;
  final String name;

  const UpdateCategory(this.categoryId, this.name);

  @override
  List<Object> get props => [categoryId, name];
}

class DeleteCategory extends CategoryEvent {
  final int categoryId;

  const DeleteCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}
