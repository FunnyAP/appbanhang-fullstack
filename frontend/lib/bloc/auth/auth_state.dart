part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  final String userName;
  final bool isAdmin;
  final String email; // Thêm trường email

  const AuthAuthenticated({
    required this.token,
    required this.userName,
    required this.isAdmin,
    required this.email,
  });

  @override
  List<Object> get props => [token, userName, isAdmin, email];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
