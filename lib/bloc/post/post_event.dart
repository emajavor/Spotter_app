part of 'post_bloc.dart';

class PostEvent extends Equatable {
  const PostEvent();

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
class AddPost extends PostEvent{
  final Array exercises;
  final DateTime duration;
  final Intensity intensity;
  final String location;
  final String photoURL;
  final String playlist;
  final String workoutType;

  const AddPost({
    required this.exercises,
    required this.duration,
    required this.intensity,
    required this.location,
    required this.photoURL,
    required this.playlist,
    required this.workoutType

  });
  @override
  List<Object> get props => [exercises, duration, intensity, location, photoURL, playlist, workoutType];

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
  List<Object> get props => [id];
}
