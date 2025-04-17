import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.network(
            category.image ??
                'https://via.placeholder.com/150', // Ảnh mặc định nếu null
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
