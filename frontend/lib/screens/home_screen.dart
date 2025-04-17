import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/product/product_bloc.dart';
import 'package:frontend/bloc/category/category_bloc.dart';
import 'package:frontend/bloc/cart/cart_bloc.dart';
import 'package:frontend/repositories/auth_repository.dart';
import 'package:frontend/widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProductBloc(
            productRepository: RepositoryProvider.of(context),
          )..add(LoadProducts()),
        ),
        BlocProvider(
          create: (context) => CategoryBloc(
            categoryRepository: RepositoryProvider.of(context),
          )..add(LoadCategories()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discover'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
          ],
        ),
        body: _buildBody(context),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(context),
        _buildCategorySection(context),
        const SizedBox(height: 16),
        Expanded(
          child: _buildProductGrid(),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search for clothes...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (query) {
          if (query.isNotEmpty) {
            BlocProvider.of<ProductBloc>(context).add(SearchProducts(query));
          } else {
            BlocProvider.of<ProductBloc>(context).add(LoadProducts());
          }
        },
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is CategoriesLoaded) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryButton(
                    title: 'All',
                    isSelected: true,
                    onPressed: () {
                      BlocProvider.of<ProductBloc>(context).add(LoadProducts());
                    },
                  ),
                  const SizedBox(width: 8),
                  ...state.categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CategoryButton(
                        title: category.name,
                        isSelected: false,
                        onPressed: () {
                          BlocProvider.of<ProductBloc>(context).add(
                              FilterProductsByCategory(
                                  categoryId: category.id));
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        } else if (state is CategoryError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Failed to load categories: ${state.message}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    BlocProvider.of<CategoryBloc>(context)
                        .add(LoadCategories());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProductGrid() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductLoaded) {
          if (state.products.isEmpty) {
            return const Center(child: Text('No products found'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.7,
            ),
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return ProductCard(product: product);
            },
          );
        } else if (state is ProductError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    BlocProvider.of<ProductBloc>(context).add(LoadProducts());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('No products available'));
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return FutureBuilder<bool>(
      future: RepositoryProvider.of<AuthRepository>(context).isAdmin(),
      builder: (context, snapshot) {
        final isAdmin = snapshot.data ?? false;

        // Trong _buildBottomNavigationBar
        return BottomNavigationBar(
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_cart),
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, state) {
                      if (state is CartLoaded) {
                        return Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${state.cart.totalItems}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_circle),
              label: isAdmin ? 'Admin' : 'Profile',
            ),
          ],
          currentIndex: 0,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index == 3) {
              // Navigate to cart screen
              Navigator.pushNamed(context, '/cart');
            } else if (index == 4) {
              if (isAdmin) {
                Navigator.pushNamed(context, '/admin');
              } else {
                Navigator.pushNamed(context, '/profile');
              }
            }
          },
        );
      },
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onPressed;

  const CategoryButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: isSelected ? Colors.black : Colors.grey),
        backgroundColor: isSelected ? Colors.black12 : Colors.transparent,
      ),
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}
