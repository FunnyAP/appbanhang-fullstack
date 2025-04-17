import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/repositories/product_repository.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;
  int currentPage = 1;
  bool hasReachedMax = false;
  final int itemsPerPage = 10;
  String? currentSearchQuery;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<SearchProducts>(_onSearchProducts);
    on<RefreshProducts>(_onRefreshProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      currentPage = 1;
      hasReachedMax = false;
      currentSearchQuery = event.query;

      final products = await productRepository.fetchProducts(
        page: currentPage,
        limit: itemsPerPage,
        searchQuery: event.query,
      );

      emit(ProductLoaded(
        products: products,
        hasReachedMax: products.length < itemsPerPage,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(ProductError(
        message: 'Failed to load products: ${e.toString()}',
        currentProducts: const [],
      ));
    }
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (state is! ProductLoaded) return;
    final currentState = state as ProductLoaded;
    if (currentState.hasReachedMax) return;

    try {
      emit(currentState.copyWith(isLoadingMore: true));

      currentPage++;
      final newProducts = await productRepository.fetchProducts(
        page: currentPage,
        limit: itemsPerPage,
        searchQuery: currentSearchQuery,
      );

      hasReachedMax = newProducts.length < itemsPerPage;

      emit(currentState.copyWith(
        products: [...currentState.products, ...newProducts],
        hasReachedMax: hasReachedMax,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(ProductError(
        message: 'Failed to load more products: ${e.toString()}',
        currentProducts: currentState.products,
      ));
      currentPage--;
    }
  }

  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<ProductState> emit,
  ) async {
    if (state is! ProductLoaded) return;
    final currentState = state as ProductLoaded;

    try {
      emit(ProductActionInProgress.fromState(currentState));

      final newProduct =
          await productRepository.createProduct(event.productData);

      emit(ProductCreatedSuccess(
        products: [newProduct, ...currentState.products],
        hasReachedMax: currentState.hasReachedMax,
        searchQuery: currentState.searchQuery,
      ));
    } catch (e) {
      emit(ProductError(
        message: 'Failed to create product: ${e.toString()}',
        currentProducts: currentState.products,
      ));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    if (state is! ProductLoaded) return;
    final currentState = state as ProductLoaded;

    try {
      emit(ProductActionInProgress.fromState(currentState));

      final updatedProduct = await productRepository.updateProduct(
        event.productId,
        event.updateData,
      );

      final updatedProducts = currentState.products
          .map((product) =>
              product.id == updatedProduct.id ? updatedProduct : product)
          .toList();

      emit(ProductUpdatedSuccess(
        products: updatedProducts,
        hasReachedMax: currentState.hasReachedMax,
        searchQuery: currentState.searchQuery,
      ));
    } catch (e) {
      emit(ProductError(
        message: 'Failed to update product: ${e.toString()}',
        currentProducts: currentState.products,
      ));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    if (state is! ProductLoaded) return;
    final currentState = state as ProductLoaded;

    try {
      emit(ProductActionInProgress.fromState(currentState));

      await productRepository.deleteProduct(event.productId);

      final updatedProducts = currentState.products
          .where((product) => product.id != event.productId)
          .toList();

      emit(ProductDeletedSuccess(
        products: updatedProducts,
        hasReachedMax: currentState.hasReachedMax,
        searchQuery: currentState.searchQuery,
      ));
    } catch (e) {
      emit(ProductError(
        message: 'Failed to delete product: ${e.toString()}',
        currentProducts: currentState.products,
      ));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      currentPage = 1;
      hasReachedMax = false;
      currentSearchQuery = event.query;

      final products = await productRepository.fetchProducts(
        page: currentPage,
        limit: itemsPerPage,
        searchQuery: event.query,
      );

      emit(ProductLoaded(
        products: products,
        hasReachedMax: products.length < itemsPerPage,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(ProductError(
        message: 'Failed to search products: ${e.toString()}',
        currentProducts: const [],
      ));
    }
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (state is! ProductLoaded) return;
    final currentState = state as ProductLoaded;

    try {
      emit(ProductRefreshing(
        products: currentState.products,
        hasReachedMax: currentState.hasReachedMax,
        searchQuery: currentState.searchQuery,
      ));

      final products = await productRepository.fetchProducts(
        page: 1,
        limit: currentState.products.length,
        searchQuery: currentState.searchQuery,
      );

      emit(currentState.copyWith(
        products: products,
        hasReachedMax: true,
      ));
    } catch (e) {
      emit(ProductError(
        message: 'Failed to refresh products: ${e.toString()}',
        currentProducts: currentState.products,
      ));
    }
  }
}
