part of 'auth_bloc.dart';

class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignInWithEmail extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmail({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignInWithGoogle extends AuthEvent {}

class SignUpWithEmail extends AuthEvent {
  final String email;
  final String password;
  final String username;

  const SignUpWithEmail({
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  List<Object> get props => [email, password, username];

}

class SignOut extends AuthEvent {}
