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

class UpdatedPost extends PostState{
  final Post updatedPost;

  UpdatedPost(this.updatedPost);
}

class FailedUpdatedPost extends PostState{
  // final Post? failedUpdatedPost;
  //
  // FailedUpdatedPost(this.failedUpdatedPost);
  final String message;

  FailedUpdatedPost(this.message);
}

class UpdatingPost extends PostState{
  final Post updatingPost;

  UpdatingPost(this.updatingPost);
}

//TODO create failed fetching state with error message attribute

