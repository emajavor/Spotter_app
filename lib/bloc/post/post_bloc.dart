import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:spotter_app/models/post.dart';

import '../../repository/firebase_repo_implementation.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final FirebaseRepo _firebaseRepo = FirebaseRepo();
  PostBloc() : super(const PostState()) {
    on<AddPost>(_onAddPost);
    on<UpdatePost>(_onUpdatePost);
    on<GetPosts>(_onGetPosts);
  }

  void _onAddPost(AddPost event, Emitter<PostState> emit) {

  }
  void _onUpdatePost(UpdatePost event, Emitter<PostState> emit) {

  }

  void _onGetPosts(GetPosts event, Emitter<PostState> emit) async {
    emit(FetchingPosts());
    try {
      print("fetching posts");
      final posts = await _firebaseRepo.getAll();
      debugPrint(posts.toString());

      emit(FetchedPosts(posts));
    } catch (e) {
      //TODO emit fetching failed state
    }
  }}
