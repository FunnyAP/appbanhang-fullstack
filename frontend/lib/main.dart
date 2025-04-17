import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:frontend/bloc/auth/auth_bloc.dart';
import 'package:frontend/bloc/product/product_bloc.dart';
import 'package:frontend/bloc/category/category_bloc.dart';
import 'package:frontend/bloc/admin/admin_bloc.dart';
import 'package:frontend/bloc/cart/cart_bloc.dart';
import 'package:frontend/bloc/order/order_bloc.dart'; // ✅ Thêm dòng này

import 'package:frontend/repositories/auth_repository.dart';
import 'package:frontend/repositories/product_repository.dart';
import 'package:frontend/repositories/category_repository.dart';
import 'package:frontend/repositories/cart_repository.dart';
import 'package:frontend/repositories/order_repository.dart'; // ✅ Thêm dòng này

import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/cart_screen.dart';
import 'package:frontend/screens/admin/admin_screen.dart';

import 'package:frontend/services/api_service.dart';

void main() {
  final dio = Dio();
  const storage = FlutterSecureStorage();
  final apiService = ApiService(dio: dio, storage: storage);

  runApp(MyApp(
    apiService: apiService,
    storage: storage,
  ));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  final FlutterSecureStorage storage;

  const MyApp({
    super.key,
    required this.apiService,
    required this.storage,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiService),
        RepositoryProvider.value(value: storage),
        RepositoryProvider(
          create: (context) => AuthRepository(
            dio: apiService.dio,
            storage: storage,
          ),
        ),
        RepositoryProvider(
          create: (context) => ProductRepository(apiService),
        ),
        RepositoryProvider(
          create: (context) => CategoryRepository(apiService),
        ),
        RepositoryProvider(
          create: (context) => CartRepository(apiService.dio),
        ),
        RepositoryProvider(
          create: (context) => OrderRepository(context.read<ApiService>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ProductBloc(
              productRepository: context.read<ProductRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => CategoryBloc(
              categoryRepository: context.read<CategoryRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => AdminBloc(
              productRepository: context.read<ProductRepository>(),
              categoryRepository: context.read<CategoryRepository>(),
            )..add(LoadProductsEvent()),
          ),
          BlocProvider(
            create: (context) => CartBloc(
              context.read<CartRepository>(),
            )..add(LoadCart()),
          ),
          BlocProvider(
            create: (context) => OrderBloc(
              // ✅ Bloc thêm mới
              context.read<OrderRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'App Ban Hang',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: true,
            ),
          ),
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginScreen(),
            '/home': (context) => HomeScreen(),
            '/admin': (context) => AdminScreen(),
            '/profile': (context) => ProfileScreen(),
            '/cart': (context) => CartScreen(),
          },
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        ),
      ),
    );
  }
}
