import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:frontend/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await authRepository.login(
        email: event.email,
        password: event.password,
      );

      if (result['status'] == 200) {
        emit(AuthAuthenticated(
          token: result['data']['token'],
          userName: result['data']['user']['name'] ?? 'User',
          isAdmin: result['data']['user']['is_admin'] ?? false,
          email: event.email, // Lưu email từ input
        ));
      } else {
        emit(AuthError(message: result['message'] ?? 'Đăng nhập thất bại'));
      }
    } on DioException catch (e) {
      emit(AuthError(
        message: e.response?.data?['message'] ?? 'Lỗi kết nối máy chủ',
      ));
    } catch (e) {
      emit(AuthError(message: 'Đã xảy ra lỗi không mong muốn'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(message: 'Đăng xuất thất bại'));
    }
  }
}
