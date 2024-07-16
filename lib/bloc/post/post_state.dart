part of 'post_bloc.dart';

class PostState extends Equatable {
  const PostState();
  @override
  List<Object?> get props => [];

}

class PostInitial extends PostState {
  const PostInitial();

  @override
  List<Object> get props => [];
}

class FetchingPosts extends PostState {

  @override
  List<Object> get props => [];
}

class FetchedPosts extends PostState{
  final List<Post> allPosts;

  const FetchedPosts(this.allPosts);


  @override
  List<Object> get props => [allPosts];
}

class FetchedPost extends PostState{
  final Post fetchedPost;

  FetchedPost(this.fetchedPost);
  @override
  List<Object> get props => [fetchedPost];
}
class FetchingFailed extends PostState{
  final String message;
  FetchingFailed(this.message);

   @override
  List<Object> get props => [message];
}


class UpdatedPost extends PostState{
  final Post updatedPost;

  UpdatedPost(this.updatedPost);
  @override
  List<Object> get props => [updatedPost];
}

class FailedUpdatedPost extends PostState{
  final String message;

  FailedUpdatedPost(this.message);

  @override
  List<Object> get props => [message];
}

class UpdatingPost extends PostState{
  @override
  List<Object> get props => [];
}

class AddedPost extends PostState{
  final Post addedPost;

  AddedPost(this.addedPost);
  @override
  List<Object> get props => [addedPost];
}
class FailedAddedPost  extends PostState{
  final String message;

  FailedAddedPost(this.message);

  @override
  List<Object> get props => [message];
}

class AddingPost extends PostState{
  @override
  List<Object> get props => [];
}


//TODO create failed fetching state with error message attribute

