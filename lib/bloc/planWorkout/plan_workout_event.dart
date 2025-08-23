part of 'plan_workout_bloc.dart';

abstract class PlanWorkoutEvent {
  const PlanWorkoutEvent();
}

class AddPlannedExercise extends PlanWorkoutEvent {
  final ExerciseEntry exercise;

  const AddPlannedExercise(this.exercise);
}

class AddNewWorkout extends PlanWorkoutEvent {
  const AddNewWorkout();
}

class ToggleExerciseCompleted extends PlanWorkoutEvent {
  final int workoutIndex;
  final int exerciseIndex;

  const ToggleExerciseCompleted(this.workoutIndex, this.exerciseIndex);
}

class ClearPlan extends PlanWorkoutEvent {
  const ClearPlan();
}