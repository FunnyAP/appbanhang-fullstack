import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/repositories/product_repository.dart';
import 'package:frontend/repositories/category_repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final ProductRepository _productRepo;
  final CategoryRepository _categoryRepo;

  AdminBloc({
    required ProductRepository productRepository,
    required CategoryRepository categoryRepository,
  })  : _productRepo = productRepository,
        _categoryRepo = categoryRepository,
        super(AdminInitial()) {
    // PRODUCT events
    on<LoadProductsEvent>(_onLoadProducts);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<AddProductEvent>(_onAddProduct);
    on<ToggleProductStatusEvent>(_onToggleProductStatus);

    // CATEGORY events
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  // ---------------- PRODUCT HANDLERS ----------------
  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final products = await _productRepo.fetchProducts();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(AdminError('Lỗi tải sản phẩm: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _productRepo.deleteProduct(event.productId);
      add(LoadProductsEvent());
    } catch (e) {
      emit(AdminError('Lỗi xóa sản phẩm: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await _productRepo.updateProduct(event.productId, event.updateData);
      add(LoadProductsEvent());
    } catch (e) {
      emit(AdminError('Lỗi cập nhật: ${e.toString()}'));
    }
  }

  Future<void> _onAddProduct(
    AddProductEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await _productRepo.createProduct(event.productData);
      add(LoadProductsEvent());
    } catch (e) {
      emit(AdminError('Lỗi thêm sản phẩm: ${e.toString()}'));
    }
  }

  Future<void> _onToggleProductStatus(
    ToggleProductStatusEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _productRepo
          .updateProduct(event.productId, {'status': event.newStatus});
      add(LoadProductsEvent());
    } catch (e) {
      emit(AdminError('Lỗi cập nhật trạng thái sản phẩm: ${e.toString()}'));
    }
  }

  // ---------------- CATEGORY HANDLERS ----------------
  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final categories = await _categoryRepo.fetchCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(AdminError('Lỗi tải danh mục: ${e.toString()}'));
    }
  }

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _categoryRepo.createCategory({
        'name': event.name,
        'slug': _generateSlug(event.name),
        'status': event.status,
      });
      add(LoadCategoriesEvent());
    } catch (e) {
      emit(AdminError('Lỗi thêm danh mục: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _categoryRepo.updateCategory(event.categoryId, {
        'name': event.name,
        'slug': _generateSlug(event.name),
        'status': event.status,
      });
      add(LoadCategoriesEvent());
    } catch (e) {
      emit(AdminError('Lỗi cập nhật danh mục: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _categoryRepo.deleteCategory(event.categoryId);
      add(LoadCategoriesEvent());
    } catch (e) {
      emit(AdminError('Lỗi xóa danh mục: ${e.toString()}'));
    }
  }

  // ---------------- HELPER ----------------
  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
  }
}
