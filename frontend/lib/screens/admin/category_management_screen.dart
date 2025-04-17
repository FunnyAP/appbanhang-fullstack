import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/admin/admin_bloc.dart';
import 'package:frontend/models/category.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý danh mục'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoriesLoaded) {
            return _buildCategoryList(state.categories);
          } else if (state is AdminError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Không có danh mục nào'));
        },
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: category.image != null && category.image!.isNotEmpty
                ? Image.network(
                    category.image!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  )
                : const Icon(Icons.category),
            title: Text(category.name),
            subtitle: Text(
                '${category.slug} • ${category.status == 1 ? "Hiển thị" : "Ẩn"}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: category.status == 1,
                  onChanged: (value) {
                    context.read<AdminBloc>().add(
                          UpdateCategoryEvent(
                              category.id, category.name, value ? 1 : 0),
                        );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () =>
                      _showCategoryDialog(context, category: category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, category.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    final nameController = TextEditingController(text: category?.name);
    int status = category?.status ?? 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(category == null ? 'Thêm danh mục mới' : 'Chỉnh sửa danh mục'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên danh mục'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                if (category == null) {
                  context
                      .read<AdminBloc>()
                      .add(AddCategoryEvent(nameController.text, status));
                } else {
                  context.read<AdminBloc>().add(
                        UpdateCategoryEvent(
                            category.id, nameController.text, status),
                      );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: const Text('Bạn có chắc chắn muốn xoá danh mục này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<AdminBloc>().add(DeleteCategoryEvent(categoryId));
              Navigator.pop(context);
            },
            child: const Text('Xoá', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
