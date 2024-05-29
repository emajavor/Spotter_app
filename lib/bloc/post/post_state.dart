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

//TODO create failed fetching state with error message attribute

