import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/auth_repository.dart';

class AdminGuard {
  static Future<bool> check(BuildContext context) async {
    try {
      final authRepo =
          RepositoryProvider.of<AuthRepository>(context, listen: false);
      final isAdmin = await authRepo.isAdmin();
      final token = await authRepo.getToken();

      if (token == null || !isAdmin) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin access required')),
          );
        });
        return false;
      }
      return true;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      });
      return false;
    }
  }
}
