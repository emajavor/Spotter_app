part of 'post_bloc.dart';

class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}
class AddPost extends PostEvent{
  final Post addedPost;

  const AddPost({required this.addedPost});

  @override
  List<Object> get props => [addedPost];
}

class AddExercises extends PostEvent {
  final ExerciseEntry exerciseEntry;
  const AddExercises({required this.exerciseEntry});
  @override
  List<Object> get props => [exerciseEntry];
}

class AddWorkoutType extends PostEvent{
  final String addedWorkoutType;

  const AddWorkoutType({required this.addedWorkoutType});

  @override
  List<Object> get props => [addedWorkoutType];
}

class AddLocation extends PostEvent{
  final String addedLocation;

  const AddLocation({required this.addedLocation});

  @override
  List<Object> get props => [addedLocation];
}
class AddPlaylist extends PostEvent{
  final String addedPlaylist;

  const AddPlaylist({required this.addedPlaylist});

  @override
  List<Object> get props => [addedPlaylist];
}

class AddImage extends PostEvent{
  final XFile? addedImage; //nullable if i add delete button later

  const AddImage({this.addedImage});

  @override
  List<Object?> get props => [addedImage];
}

class GetPosts extends PostEvent {
  final String userId;

  const GetPosts({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetPost extends PostEvent {
  final String id;
  final String userId;

  const GetPost({required this.id, required this.userId});

  @override
  List<Object?> get props => [id, userId];
}

class ToggleLikePost extends PostEvent {
  final String postId;
  final String userId;

  const ToggleLikePost(this.postId, this.userId);

  @override
  List<Object?> get props => [postId, userId];
}

class AddComment extends PostEvent {
  final String postId;
  final Comment comment;

  const AddComment(this.postId, this.comment);

  @override
  List<Object?> get props => [postId, comment];
}

class GetWeeklyTotals extends PostEvent {
  final String userId;
  const GetWeeklyTotals(this.userId);
  @override
  List<Object> get props => [userId];
}

class TogglePostVisibility extends PostEvent {
  final bool isPublic;

  const TogglePostVisibility(this.isPublic);

  @override
  List<Object?> get props => [isPublic];
}
