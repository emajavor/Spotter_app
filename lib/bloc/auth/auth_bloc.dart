import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(AuthInitial()) {
    on<SignInWithEmail>(_onSignInWithEmail);
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SignUpWithEmail>(_onSignUpWithEmail);
    on<SignOut>(_onSignOut);

    //checking the current when starting the app
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      emit(AuthAuthenticated(
        userId: currentUser.uid,
        email: currentUser.email!,
      ));
    }
  }

  Future<void> _onSignInWithEmail(SignInWithEmail event, Emitter<AuthState> emit) async{
    emit(AuthLoading());
    try{
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: event.email, password: event.password,);
      emit(AuthAuthenticated(userId: userCredential.user!.uid, email: userCredential.user!.email!,));
    }
    catch(e){
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
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      emit(AuthAuthenticated(
        userId: userCredential.user!.uid,
        email: userCredential.user!.email!,
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
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': event.email,
        'username': event.username,
        'createdAt': FieldValue.serverTimestamp(),
      });
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