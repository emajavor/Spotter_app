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

  const FetchingPosts();
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
  final String error;

  const FetchingFailed(this.error);

   @override
  List<Object> get props => [error];
}

class AddedPost extends PostState{
  final Post? addedPost;

  const AddedPost([this.addedPost]);

  @override
  List<Object?> get props => [addedPost];
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

  const EmptyLocation();
}

class AddedPlaylist extends PostState{
  final String addedPlaylist;

  const AddedPlaylist(this.addedPlaylist);

  @override
  List<Object> get props => [addedPlaylist];
}

class EmptyPlaylist extends PostState{

  const EmptyPlaylist();
}

class AddedExercises extends PostState {
  final List<ExerciseEntry> exercises;
  const AddedExercises(this.exercises);
  @override
  List<Object> get props => [exercises];
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

  const EmptyImage();
}

class FailedAddedPost  extends PostState{
  final String error;

  const FailedAddedPost(this.error);

  @override
  List<Object> get props => [error];
}

class AddingPost extends PostState{

  const AddingPost();
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

class FetchingWeeklyTotals extends PostState {
  const FetchingWeeklyTotals();
}

class FetchedWeeklyTotals extends PostState {
  final Map<String, int> muscleSets;
  final Map<String, String> muscleStatus;
  const FetchedWeeklyTotals(this.muscleSets, this.muscleStatus);
  @override
  List<Object> get props => [muscleSets, muscleStatus];
}

class FailedWeeklyTotals extends PostState {
  final String error;
  const FailedWeeklyTotals(this.error);
  @override
  List<Object> get props => [error];
}

class FailedFetchedPost extends PostState {
  final String error;
  const FailedFetchedPost(this.error);
}
