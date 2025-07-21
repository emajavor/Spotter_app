part of 'post_bloc.dart';

class PostEvent extends Equatable {
  const PostEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}
class AddPost extends PostEvent{
  final Post addedPost;

  const AddPost({required this.addedPost});

  @override
  List<Object> get props => [addedPost];
}

class AddExercises extends PostEvent{
  final String addedExercises;

  const AddExercises({required this.addedExercises});

  @override
  List<Object> get props => [addedExercises];
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
  final XFile? addedImage; //nullable za kasnije ako budem dodavala gumb za brisanje

  const AddImage({this.addedImage});

  @override
  List<Object?> get props => [addedImage];
}

class UpdatePost extends PostEvent{
  final String id;
  final Intensity newIntensity;

  const UpdatePost({
    required this.id,
    required this.newIntensity
  });

  @override
  List<Object> get props => [id, newIntensity];
}

class GetPosts extends PostEvent{
  const GetPosts();

  @override
  List<Object> get props => [];
}

class GetPost extends PostEvent{
  final String id;
  final Intensity intensity;

  const GetPost({
    required this.id,
    required this.intensity
  });

  @override
  List<Object> get props => [id, intensity];
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
