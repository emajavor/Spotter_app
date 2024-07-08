import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:spotter_app/models/enums/intensity.dart';
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
    on<GetPost>(_onGetPost);
  }

  void _onAddPost(AddPost event, Emitter<PostState> emit) {

  }
  void _onUpdatePost(UpdatePost event, Emitter<PostState> emit) async {
    print('Updating post with id: ${event.id} to intensity: ${event.newIntensity}');
    //updatePost event sadrzi id i intensity novi
      try {
        await _firebaseRepo.updateField(event.id, event.newIntensity.description); //updateam post tj field
        add(GetPost(id: event.id, intensity: event.newIntensity)); //fetcham updated post
      } catch(e) {
        emit(FailedUpdatedPost(e.toString()));
      }
  }

  void _onGetPosts(GetPosts event, Emitter<PostState> emit) async {
    emit(FetchingPosts());
    try {
      print("fetching posts");
      final posts = await _firebaseRepo.getAll();
      debugPrint(posts.toString());

      emit(FetchedPosts(posts));
    } catch (e) {
      emit(FetchingFailed(e.toString()));    }
  }



  FutureOr<void> _onGetPost(GetPost event, Emitter<PostState> emit) async {
    try {
      Post? post = await _firebaseRepo.getPost(event.id);//fetcha post s tim id-em

      if (post != null) {
        emit(UpdatedPost(post));
      } else {
        emit(FailedUpdatedPost("No post"));
      }
    } catch(e) {
        emit(FailedUpdatedPost("Failed to update Post"));
    }
  }
}
