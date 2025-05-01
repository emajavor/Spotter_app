part of 'auth_bloc.dart';

class AuthState extends Equatable{
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState{
  final String userId;
  final String email;
  final String? username;

  const AuthAuthenticated({
    required this.userId,
    required this.email,
    this.username,
  });

  @override
  List<Object> get props => [userId, email];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}