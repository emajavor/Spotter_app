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
  final Post post;
  const UpdatePost({
    required this.post,
  });
  @override
  List<Object> get props => [post];

}
class GetPosts extends PostEvent{
  const GetPosts();
  @override
  List<Object> get props => [];
}
