import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/bloc/admin/admin_bloc.dart';
import 'package:frontend/models/product.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadProductsEvent());
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _selectedImage = null;
              });
              _showProductDialog(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductsLoaded) {
            return _buildProductList(state.products);
          } else if (state is AdminError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Không có sản phẩm nào'));
        },
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: product.imageUrl != null &&
                    'http://127.0.0.1:8000/image-proxy/${product.image}'
                        .isNotEmpty
                ? Image.network(
                    'http://127.0.0.1:8000/image-proxy/${product.image}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  )
                : const Icon(Icons.image),
            title: Text(product.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.formattedPrice),
                Text('Tồn kho: ${product.stock}'),
                Text('Trạng thái: ${product.status ? "Hiển thị" : "Ẩn"}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: product.status,
                  onChanged: (value) {
                    context.read<AdminBloc>().add(
                          ToggleProductStatusEvent(product.id, value ? 1 : 0),
                        );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                    });
                    _showProductDialog(context, product: product);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteProduct(context, product.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProductDialog(BuildContext context, {Product? product}) {
    final nameController = TextEditingController(text: product?.name);
    final slugController = TextEditingController(text: product?.slug);
    final descriptionController =
        TextEditingController(text: product?.description);
    final priceController =
        TextEditingController(text: product?.price.toString());
    final stockController =
        TextEditingController(text: product?.stock.toString());
    final categoryIdController =
        TextEditingController(text: product?.categoryId.toString());
    bool status = product?.status ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(product == null ? 'Thêm sản phẩm mới' : 'Chỉnh sửa sản phẩm'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
              ),
              TextField(
                controller: slugController,
                decoration: const InputDecoration(labelText: 'Slug'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giá'),
              ),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tồn kho'),
              ),
              TextField(
                controller: categoryIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ID danh mục'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Chọn ảnh"),
              ),
              if (_selectedImage != null)
                FutureBuilder<Uint8List>(
                  future: _selectedImage!.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return Image.memory(snapshot.data!, height: 100);
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              if (_selectedImage == null &&
                  product?.imageUrl != null &&
                  product!.imageUrl!.isNotEmpty)
                Image.network(
                    'http://127.0.0.1:8000/image-proxy/${product.image}',
                    height: 100),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse(
                  'http://127.0.0.1:8000/api/products${product == null ? '' : '/${product.id}'}');
              final request = http.MultipartRequest('POST', uri);

              request.fields.addAll({
                'name': nameController.text,
                'slug': slugController.text,
                'description': descriptionController.text,
                'price': priceController.text,
                'stock': stockController.text,
                'category_id': categoryIdController.text,
                'status': status ? '1' : '0',
              });

              if (product != null) {
                request.fields['_method'] = 'PUT';
              }

              if (_selectedImage != null) {
                final bytes = await _selectedImage!.readAsBytes();
                final fileName = _selectedImage!.name;
                request.files.add(
                  http.MultipartFile.fromBytes('image', bytes,
                      filename: fileName),
                );
              }

              final response = await request.send();
              final responseBody = await response.stream.bytesToString();
              debugPrint("🔄 Status code: \${response.statusCode}");
              debugPrint("📦 Response body: \$responseBody");

              if (response.statusCode == 201 || response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(product == null
                          ? '🎉 Thêm sản phẩm thành công'
                          : '✅ Cập nhật thành công')),
                );
                context.read<AdminBloc>().add(LoadProductsEvent());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Thao tác thất bại')),
                );
              }

              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context, int productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn chắc chắn muốn xóa sản phẩm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<AdminBloc>().add(DeleteProductEvent(productId));
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
