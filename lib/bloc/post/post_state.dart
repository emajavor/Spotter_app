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

  const FetchedPost(this.fetchedPost);

  @override
  List<Object> get props => [fetchedPost];
}
class FetchingFailed extends PostState{
  final String message;

  const FetchingFailed(this.message);

   @override
  List<Object> get props => [message];
}

class UpdatedPost extends PostState{
  final Post updatedPost;

  const UpdatedPost(this.updatedPost);

  @override
  List<Object> get props => [updatedPost];
}

class FailedUpdatedPost extends PostState{
  final String message;

  const FailedUpdatedPost(this.message);

  @override
  List<Object> get props => [message];
}

class UpdatingPost extends PostState{

  @override
  List<Object> get props => [];
}

class AddedPost extends PostState{
  final Post addedPost;

  const AddedPost(this.addedPost);

  @override
  List<Object> get props => [addedPost];
}

class AddedWorkoutType extends PostState{
  final String addedWorkoutType;

  const AddedWorkoutType(this.addedWorkoutType);

  @override
  List<Object> get props => [addedWorkoutType];
}

class EmptyWorkoutType extends PostState{

  @override
  List<Object> get props => [];
}

class AddedLocation extends PostState{
  final String addedLocation;

  const AddedLocation(this.addedLocation);

  @override
  List<Object> get props => [addedLocation];
}

class EmptyLocation extends PostState{

  @override
  List<Object> get props => [];
}

class AddedPlaylist extends PostState{
  final String addedPlaylist;

  const AddedPlaylist(this.addedPlaylist);

  @override
  List<Object> get props => [addedPlaylist];
}

class EmptyPlaylist extends PostState{

  @override
  List<Object> get props => [];
}

class AddedExercises extends PostState{
  final List<String> addedExercises;

  const AddedExercises(this.addedExercises);

  @override
  List<Object> get props => [addedExercises];
}

class EmptyExercises extends PostState{

  @override
  List<Object> get props => [];
}

class AddedImage extends PostState{
  final XFile addedImage;

  const AddedImage(this.addedImage);

  @override
  List<Object> get props => [addedImage];
}

class EmptyImage extends PostState{

  @override
  List<Object> get props => [];
}

class FailedAddedPost  extends PostState{
  final String message;

  const FailedAddedPost(this.message);

  @override
  List<Object> get props => [message];
}

class AddingPost extends PostState{

  @override
  List<Object> get props => [];
}

class AddingExercise extends PostState {

  const AddingExercise();

  @override
  List<Object> get props => [];
}

class AddingWorkoutType extends PostState {

  const AddingWorkoutType();

  @override
  List<Object> get props => [];
}

class AddingLocation extends PostState {

  const AddingLocation();

  @override
  List<Object> get props => [];
}

class AddingPlaylist extends PostState {

  const AddingPlaylist();

  @override
  List<Object> get props => [];
}

class AddingImage extends PostState {

  const AddingImage();

  @override
  List<Object> get props => [];
}

//TODO create failed fetching state with error message attribute

