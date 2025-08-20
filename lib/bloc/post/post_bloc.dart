import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotter_app/models/enums/intensity.dart';
import 'package:spotter_app/models/post.dart';
import 'package:spotter_app/utils/muscle_analyzer.dart';

import '../../repository/firebase_repo_implementation.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final FirebaseRepo _firebaseRepo;
  final List<ExerciseEntry> _exercises = [];
  String _workoutType = "";
  String _location = "";
  String _playlist = "";
  XFile? _image;

  String get workoutType => _workoutType;
  String get location => _location;
  String get playlist => _playlist;
  List<ExerciseEntry> get exercises => _exercises;

  PostBloc(this._firebaseRepo) : super(const PostState()) {
    on<AddWorkoutType>(_onAddWorkoutType);
    on<AddLocation>(_onAddLocation);
    on<AddPlaylist>(_onAddPlaylist);
    on<AddExercises>(_onAddExercises);
    on<AddImage>(_onAddImage);
    on<AddPost>(_onAddPost);
    on<GetPosts>(_onGetPosts);
    on<GetPost>(_onGetPost);
    on<ToggleLikePost>(_onToggleLikePost);
    on<AddComment>(_onAddComment);
    on<GetWeeklyTotals>(_onGetWeeklyTotals);
  }

  Future<void> _onAddPost(AddPost event, Emitter<PostState> emit) async {
    emit(const AddingPost());
    try {
      await _firebaseRepo.addPost(event.addedPost);
      emit(AddedPost(event.addedPost));
      _exercises.clear();
      _workoutType = "";
      _location = "";
      _playlist = "";
      _image = null;
      add(const GetPosts());
    } catch (e) {
      print("Error in AddPost: $e");
      emit(FailedAddedPost(e.toString()));
    }
  }

  FutureOr <void> _onAddWorkoutType(AddWorkoutType event, Emitter<PostState> emit)  {
    emit(const AddingWorkoutType());
    _workoutType = event.addedWorkoutType;
    if(_workoutType.isEmpty){
      emit(EmptyWorkoutType());
    }
    else {
      emit(AddedWorkoutType(_workoutType));
    }
  }

  FutureOr <void> _onAddLocation(AddLocation event, Emitter<PostState> emit)  {
    emit(const AddingLocation());
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
    emit(const AddingPlaylist());
    _playlist = event.addedPlaylist;
    if(_playlist.isEmpty){
      emit(EmptyPlaylist());

    }
    else {
      emit(AddedPlaylist(_playlist));
    }
  }

  FutureOr<void> _onAddExercises(AddExercises event, Emitter<PostState> emit) {
    emit(const AddingExercise());
    _exercises.add(event.exerciseEntry);
    if (_exercises.isEmpty) {
      emit(EmptyExercises());
    } else {
      emit(AddedExercises(_exercises));
    }
  }

  FutureOr<void> _onAddImage(AddImage event, Emitter<PostState> emit)  {
    emit(const AddingImage());
    _image = event.addedImage;
    if(_image != null){
      emit(AddedImage(_image!));
    }
    else {
      emit(const EmptyImage());
    }
  }

  void _onGetPosts(GetPosts event, Emitter<PostState> emit) async {
    emit(const FetchingPosts());
    try {
      final posts = await _firebaseRepo.getAll();
      // Sort newest first, with fallback for non-numeric IDs
      final sortedPosts = posts
        ..sort((a, b) {
          try {
            return int.parse(b.id).compareTo(int.parse(a.id));
          } catch (e) {
            return b.id.compareTo(a.id);
          }
        });
      emit(FetchedPosts(sortedPosts));
    } catch (e) {
      emit(FetchingFailed(e.toString()));
    }
  }

  FutureOr<void> _onGetPost(GetPost event, Emitter<PostState> emit) async {
    try {
      Post? post = await _firebaseRepo.getPost(event.id);
      if (post != null) {
        emit(FetchedPost(post));
      } else {
        emit(const FailedFetchedPost("Post not found"));
      }
    } catch (e) {
      emit(FailedFetchedPost("Failed to fetch post: ${e.toString()}"));
    }
  }

  void _onToggleLikePost(ToggleLikePost event, Emitter<PostState> emit) async {
    final currentState = state;
    if (currentState is FetchedPosts) {
      try {
        final updatedPosts = currentState.allPosts.map((post) {
          if (post.id == event.postId) {
            final newLikes = List<String>.from(post.likes);
            if (newLikes.contains(event.userId)) {
              newLikes.remove(event.userId);
            } else {
              newLikes.add(event.userId);
            }
            return post.copyWith(likes: newLikes);
          }
          return post;
        }).toList();
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(event.postId)
            .update({'likes': FieldValue.arrayUnion([event.userId])});
        emit(FetchedPosts(updatedPosts));
      } catch (e) {
        emit(FetchingFailed(e.toString()));
      }
    }
  }

  void _onAddComment(AddComment event, Emitter<PostState> emit) async {
    final currentState = state;
    if (currentState is FetchedPosts) {
      try {
        final updatedPosts = currentState.allPosts.map((post) {
          if (post.id == event.postId) {
            final newComments = List<Comment>.from(post.comments)..add(event.comment);
            return post.copyWith(comments: newComments);
          }
          return post;
        }).toList();
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(event.postId)
            .update({
          'comments': FieldValue.arrayUnion([event.comment.toJson()])
        });
        emit(FetchedPosts(updatedPosts));
      } catch (e) {
        emit(FetchingFailed(e.toString()));
      }
    }
  }

  void _onGetWeeklyTotals(GetWeeklyTotals event, Emitter<PostState> emit) async {
    emit(const FetchingWeeklyTotals());
    try {
      final posts = await _firebaseRepo.getUserPostsInLastWeek(event.userId);
      final muscleSets = MuscleAnalyzer.calculateMuscleSets(posts);
      final muscleStatus = MuscleAnalyzer.classifyMuscleLoad(muscleSets);
      emit(FetchedWeeklyTotals(muscleSets, muscleStatus));
    } catch (e) {
      emit(FailedWeeklyTotals(e.toString()));
    }
  }
}