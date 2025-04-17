part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  final List<Product> products;
  final bool hasReachedMax;
  final String? searchQuery;
  final bool isLoadingMore;
  final bool isRefreshing;

  const ProductState({
    this.products = const [],
    this.hasReachedMax = false,
    this.searchQuery,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  ProductState copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    String? searchQuery,
    bool? isLoadingMore,
    bool? isRefreshing,
  });

  @override
  List<Object?> get props => [
        products,
        hasReachedMax,
        searchQuery,
        isLoadingMore,
        isRefreshing,
      ];
}

class ProductInitial extends ProductState {
  const ProductInitial();

  @override
  ProductInitial copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    String? searchQuery,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return const ProductInitial();
  }
}

class ProductLoading extends ProductState {
  const ProductLoading();

  @override
  ProductLoading copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    String? searchQuery,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return const ProductLoading();
  }
}

class ProductRefreshing extends ProductState {
  const ProductRefreshing({
    required List<Product> products,
    required bool hasReachedMax,
    String? searchQuery,
  }) : super(
          products: products,
          hasReachedMax: hasReachedMax,
          searchQuery: searchQuery,
          isRefreshing: true,
        );

  @override
  ProductRefreshing copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    String? searchQuery,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return ProductRefreshing(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProductLoaded extends ProductState {
  const ProductLoaded({
    required List<Product> products,
    required bool hasReachedMax,
    String? searchQuery,
    bool isLoadingMore = false,
  }) : super(
          products: products,
          hasReachedMax: hasReachedMax,
          searchQuery: searchQuery,
          isLoadingMore: isLoadingMore,
        );

  @override
  ProductLoaded copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    String? searchQuery,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ProductActionInProgress extends ProductState {
  const ProductActionInProgress({
    required List<Product> products,
    required bool hasReachedMax,
    String? searchQuery,
  }) : super(
          products: products,
          hasReachedMax: hasReachedMax,
          searchQuery: searchQuery,
        );

  factory ProductActionInProgress.fromState(ProductState state) {
    return ProductActionInProgress(
      products: state.products,
      hasReachedMax: state.hasReachedMax,
      searchQuery: state.searchQuery,
    );
  }

  @override
  ProductActionInProgress copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    String? searchQuery,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return ProductActionInProgress(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProductCreatedSuccess extends ProductLoaded {
  const ProductCreatedSuccess({
    required List<Product> products,
    required bool hasReachedMax,
    String? searchQuery,
  }) : super(
          products: products,
          hasReachedMax: hasReachedMax,
          searchQuery: searchQuery,
        );

  @override
  ProductCreatedSuccess copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    String? searchQuery,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return ProductCreatedSuccess(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProductUpdatedSuccess extends ProductLoaded {
  const ProductUpdatedSuccess({
    required List<Product> products,
    required bool hasReachedMax,
    String? searchQuery,
  }) : super(
          products: products,
          hasReachedMax: hasReachedMax,
          searchQuery: searchQuery,
        );

  @override
  ProductUpdatedSuccess copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    String? searchQuery,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return ProductUpdatedSuccess(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProductDeletedSuccess extends ProductLoaded {
  const ProductDeletedSuccess({
    required List<Product> products,
    required bool hasReachedMax,
    String? searchQuery,
  }) : super(
          products: products,
          hasReachedMax: hasReachedMax,
          searchQuery: searchQuery,
        );

  @override
  ProductDeletedSuccess copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    String? searchQuery,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return ProductDeletedSuccess(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProductError extends ProductState {
  final String message;

  const ProductError({
    required this.message,
    required List<Product> currentProducts,
    bool hasReachedMax = false,
    String? searchQuery,
  }) : super(
          products: currentProducts,
          hasReachedMax: hasReachedMax,
          searchQuery: searchQuery,
        );

  @override
  ProductError copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    String? searchQuery,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? message,
  }) {
    return ProductError(
      message: message ?? this.message,
      currentProducts: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [message, ...super.props];
}
