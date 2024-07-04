part of 'post_bloc.dart';

class PostEvent extends Equatable {
  const PostEvent();

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
class AddPost extends PostEvent{
  final Post post;
  const AddPost({
    required this.post,
  });
  @override
  List<Object> get props => [post];

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
