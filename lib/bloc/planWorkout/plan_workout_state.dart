part of 'plan_workout_bloc.dart';

class PlanWorkoutState {
  final List<Post> workouts;
  final Map<String, int> muscleSets;
  final Map<String, String> muscleStatus;
  final Map<String, String> muscleRecommendations;

  const PlanWorkoutState({
    this.workouts = const [],
    this.muscleSets = const {},
    this.muscleStatus = const {},
    this.muscleRecommendations = const {},
  });
}