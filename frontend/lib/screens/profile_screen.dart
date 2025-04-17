import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/auth/auth_bloc.dart';
import 'package:frontend/repositories/auth_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = RepositoryProvider.of<AuthRepository>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin tài khoản'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([
          authRepo.storage.read(key: 'user_name'),
          authRepo.storage.read(key: 'user_email'),
          authRepo.storage.read(key: 'is_admin'),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ${snapshot.data?[0] ?? 'User'}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Email: ${snapshot.data?[1] ?? 'Chưa có thông tin'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Quyền: ${snapshot.data?[2] == 'true' ? 'Admin' : 'User'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Chỉnh sửa thông tin'),
                  onTap: () {
                    // TODO: Thêm màn hình chỉnh sửa
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Đổi mật khẩu'),
                  onTap: () {
                    // TODO: Thêm màn hình đổi mật khẩu
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
