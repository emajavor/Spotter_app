import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spotter_app/models/user.dart';

import '../../repository/firebase_repo_implementation.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseRepo _firebaseRepo;

  AuthBloc(this._firebaseRepo) : super(AuthInitial()) {
    on<SignInWithEmail>(_onSignInWithEmail);
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SignUpWithEmail>(_onSignUpWithEmail);
    on<SignOut>(_onSignOut);
  }

  Future<void> _onSignInWithEmail(SignInWithEmail event, Emitter<AuthState> emit) async{
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      final user = await _firebaseRepo.getUser(userCredential.user!.uid);
      emit(AuthAuthenticated(
        userId: userCredential.user!.uid,
        email: userCredential.user!.email!,
        username: user?.username,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInWithGoogle(SignInWithGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(AuthUnauthenticated());
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final existingUser = await _firebaseRepo.getUser(userCredential.user!.uid);
      if (existingUser == null) {
        final user = User(
          uid: userCredential.user!.uid,
          username: googleUser.displayName ?? 'User',
          email: googleUser.email,
          createdAt: Timestamp.now(),
          profilePictureUrl: googleUser.photoUrl ?? '',
        );
        await _firebaseRepo.saveUser(user);
      }
      final user = await _firebaseRepo.getUser(userCredential.user!.uid);
      emit(AuthAuthenticated(
        userId: userCredential.user!.uid,
        email: userCredential.user!.email!,
        username: user?.username,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpWithEmail(SignUpWithEmail event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      final user = User(
        uid: userCredential.user!.uid,
        username: event.username,
        email: event.email,
        createdAt: Timestamp.now(),
        profilePictureUrl: '',
      );
      await _firebaseRepo.saveUser(user);
      emit(AuthAuthenticated(
        userId: userCredential.user!.uid,
        email: userCredential.user!.email!,
        username: event.username,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    emit(AuthUnauthenticated());
  }
}