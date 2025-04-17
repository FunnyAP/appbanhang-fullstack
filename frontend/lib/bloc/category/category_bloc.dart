import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/repositories/category_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryBloc({required this.categoryRepository}) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(CategoryLoading());
      final categories = await categoryRepository.fetchCategories();
      print('Loaded categories: ${categories.length}'); // Debug
      emit(CategoriesLoaded(categories: categories));
    } catch (e) {
      print('Error loading categories: $e'); // Debug
      emit(
          CategoryError(message: 'Failed to load categories: ${e.toString()}'));
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      if (state is CategoriesLoaded) {
        final currentState = state as CategoriesLoaded;
        emit(CategoryLoading());
        final newCategory = await categoryRepository.createCategory({
          'name': event.name,
        });
        emit(CategoriesLoaded(
          categories: [...currentState.categories, newCategory],
        ));
      }
    } catch (e) {
      emit(CategoryError(message: 'Failed to add category: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      if (state is CategoriesLoaded) {
        final currentState = state as CategoriesLoaded;
        emit(CategoryLoading());
        final updatedCategory = await categoryRepository.updateCategory(
          event.categoryId,
          {'name': event.name},
        );
        final updatedCategories = currentState.categories.map((category) {
          return category.id == event.categoryId ? updatedCategory : category;
        }).toList();
        emit(CategoriesLoaded(categories: updatedCategories));
      }
    } catch (e) {
      emit(
          CategoryError(message: 'Failed to update category: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      if (state is CategoriesLoaded) {
        final currentState = state as CategoriesLoaded;
        emit(CategoryLoading());
        await categoryRepository.deleteCategory(event.categoryId);
        emit(CategoriesLoaded(
          categories: currentState.categories
              .where((category) => category.id != event.categoryId)
              .toList(),
        ));
      }
    } catch (e) {
      emit(
          CategoryError(message: 'Failed to delete category: ${e.toString()}'));
    }
  }
}
