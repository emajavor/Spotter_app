import 'dart:async';
import 'dart:ffi';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotter_app/models/enums/intensity.dart';
import 'package:spotter_app/models/post.dart';

import '../../repository/firebase_repo_implementation.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final FirebaseRepo _firebaseRepo = FirebaseRepo();
  List<String> _exercises = [];
  String _workoutType = "";
  String _location = "";
  String _playlist = "";
  XFile? _image;
  PostBloc() : super(const PostState()) {
    on<AddWorkoutType>(_onAddWorkoutType);
    on<AddLocation>(_onAddLocation);
    on<AddPlaylist>(_onAddPlaylist);
    on<AddExercises>(_onAddExercises);
    on<AddImage>(_onAddImage);
    //on<AddPost>(_onAddPost);
    on<UpdatePost>(_onUpdatePost);
    on<GetPosts>(_onGetPosts);
    on<GetPost>(_onGetPost);
  }

  FutureOr <void> _onAddWorkoutType(AddWorkoutType event, Emitter<PostState> emit)  {
    emit(AddingWorkoutType());
    _workoutType = event.addedWorkoutType;
    if(_workoutType.isEmpty){
      emit(EmptyWorkoutType());
    }
    else {
      emit(AddedWorkoutType(_workoutType));
    }
  }

  FutureOr <void> _onAddLocation(AddLocation event, Emitter<PostState> emit)  {
    emit(AddingLocation());
    _location = event.addedLocation;
    print("LOCATION: ${event.addedLocation}");
    if(_location.isEmpty){
      emit(EmptyLocation());
    }
    else {
      emit(AddedLocation(_location));
    }
  }

  Future <void> _onAddPlaylist(AddPlaylist event, Emitter<PostState> emit) async {
    emit(AddingPlaylist());
    _playlist = event.addedPlaylist;
    if(_playlist.isEmpty){
      emit(EmptyPlaylist());

    }
    else {
      print("PLAYLIST: $_playlist");
      emit(AddedPlaylist(_playlist));
    }
  }

  FutureOr <void> _onAddExercises(AddExercises event, Emitter<PostState> emit)  {
    emit(AddingExercise());
    _exercises.add(event.addedExercises);
    if(_exercises.isEmpty){
      emit(EmptyExercises());
    }
    else {
      emit(AddedExercises(_exercises));
    }
  }

  FutureOr <void> _onAddImage(AddImage event, Emitter<PostState> emit)  {
    emit(AddingImage());
    _image = event.addedImage;
    if(_image != null){
      emit(EmptyImage());
    }
    else {
      emit(AddedImage(_image!));
    }
  }

  // Future<void> _onAddPost(AddPost event, Emitter<PostState> emit) async {
  //   Post addedPost = Post(id: id, duration: duration, location: location, photoURL: photoURL, playlist: playlist, workout_type: _workoutType, intensity: intensity, exercises: exercises)
  //
  //   try {
  //       await _firebaseRepo.addPost(addedPost);
  //     } catch(e) {
  //       print("error za addedpost $e");
  //       emit(FailedAddedPost(e.toString()));
  //     }
  // }
  void _onUpdatePost(UpdatePost event, Emitter<PostState> emit) async {
    print('Updating post with id: ${event.id} to intensity: ${event.newIntensity}');
      try {
        await _firebaseRepo.updateField(event.id, event.newIntensity.description);
        add(GetPost(id: event.id, intensity: event.newIntensity));
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
      Post? post = await _firebaseRepo.getPost(event.id);

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


