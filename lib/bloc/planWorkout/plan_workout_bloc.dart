import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter_app/models/post.dart';
import 'package:spotter_app/utils/muscle_analyzer.dart';
import 'package:spotter_app/ml/workout_model.dart';

import '../../models/enums/intensity.dart';

part 'plan_workout_event.dart';
part 'plan_workout_state.dart';

class PlanWorkoutBloc extends Bloc<PlanWorkoutEvent, PlanWorkoutState> {
  final WorkoutModel _workoutModel;
  final List<Post> _plannedWorkouts = [];

  PlanWorkoutBloc(this._workoutModel) : super(const PlanWorkoutState()) {
    on<AddPlannedExercise>(_onAddPlannedExercise);
    on<AddNewWorkout>(_onAddNewWorkout);
    on<ToggleExerciseCompleted>(_onToggleExerciseCompleted);
    on<ClearPlan>(_onClearPlan);
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    await _workoutModel.init();
  }

  FutureOr<void> _onAddPlannedExercise(AddPlannedExercise event, Emitter<PlanWorkoutState> emit) {
    List<Post> updatedWorkouts = _plannedWorkouts
        .map((workout) => workout.copyWith(
      exercises: workout.exercises
          .map((exercise) => exercise.copyWith(
        name: exercise.name,
        muscleGroups: List.from(exercise.muscleGroups),
        sets: exercise.sets,
        isCompleted: exercise.isCompleted,
      ))
          .toList(),
    ))
        .toList();

    if (updatedWorkouts.isEmpty) {
      updatedWorkouts.add(Post(
        id: 'workout_${updatedWorkouts.length + 1}',
        date: DateTime.now(),
        location: '',
        photoURL: '',
        playlist: '',
        workout_type: 'Workout ${updatedWorkouts.length + 1}',
        intensity: Intensity.none,
        exercises: [],
        userId: '',
        username: '',
        likes: const [],
        comments: const [],
      ));
    }


    final currentWorkout = updatedWorkouts.last;
    final updatedExercises = List<ExerciseEntry>.from(currentWorkout.exercises)
      ..add(event.exercise.copyWith(
        name: event.exercise.name,
        muscleGroups: List.from(event.exercise.muscleGroups),
        sets: event.exercise.sets,
        isCompleted: event.exercise.isCompleted,
      ));
    updatedWorkouts.last = currentWorkout.copyWith(exercises: updatedExercises);

    _plannedWorkouts.clear();
    _plannedWorkouts.addAll(updatedWorkouts);

    final muscleSets = MuscleAnalyzer.calculateMuscleSets(updatedWorkouts);
    final muscleStatus = <String, String>{};
    final muscleRecommendations = <String, String>{};

    for (var muscle in muscleSets.keys) {
      final sets = muscleSets[muscle]!;
      final pred = _workoutModel.predict(
        muscle: muscle,
        soFar: sets,
        toAdd: 0,
      );
      final labels = ['Undertrained', 'Balanced', 'Overtrained'];
      muscleStatus[muscle] = labels[pred];
      if (pred == 0) {
        muscleRecommendations[muscle] = 'Add ${10 - sets}-${20 - sets} sets';
      } else if (pred == 2) {
        muscleRecommendations[muscle] = 'Reduce by ${sets - 20} sets';
      } else {
        muscleRecommendations[muscle] = 'Balanced';
      }
    }

    emit(PlanWorkoutState(
      workouts: List.from(updatedWorkouts),
      muscleSets: Map.from(muscleSets),
      muscleStatus: Map.from(muscleStatus),
      muscleRecommendations: Map.from(muscleRecommendations),
    ));
  }

  FutureOr<void> _onAddNewWorkout(AddNewWorkout event, Emitter<PlanWorkoutState> emit) {
    List<Post> updatedWorkouts = _plannedWorkouts
        .map((workout) => workout.copyWith(
      exercises: workout.exercises
          .map((exercise) => exercise.copyWith(
        name: exercise.name,
        muscleGroups: List.from(exercise.muscleGroups),
        sets: exercise.sets,
        isCompleted: exercise.isCompleted,
      ))
          .toList(),
    ))
        .toList();

    updatedWorkouts.add(Post(
      id: 'workout_${updatedWorkouts.length + 1}',
      date: DateTime.now(),
      location: '',
      photoURL: '',
      playlist: '',
      workout_type: 'Workout ${updatedWorkouts.length + 1}',
      intensity: Intensity.none,
      exercises: [],
      userId: '',
      username: '',
      likes: const [],
      comments: const [],
    ));

    _plannedWorkouts.clear();
    _plannedWorkouts.addAll(updatedWorkouts);

    final muscleSets = MuscleAnalyzer.calculateMuscleSets(updatedWorkouts);
    final muscleStatus = <String, String>{};
    final muscleRecommendations = <String, String>{};

    for (var muscle in muscleSets.keys) {
      final sets = muscleSets[muscle]!;
      final pred = _workoutModel.predict(
        muscle: muscle,
        soFar: sets,
        toAdd: 0,
      );
      final labels = ['Undertrained', 'Balanced', 'Overtrained'];
      muscleStatus[muscle] = labels[pred];
      if (pred == 0) {
        muscleRecommendations[muscle] = 'Add ${10 - sets}-${20 - sets} sets';
      } else if (pred == 2) {
        muscleRecommendations[muscle] = 'Reduce by ${sets - 20} sets';
      } else {
        muscleRecommendations[muscle] = 'Balanced';
      }
    }

    emit(PlanWorkoutState(
      workouts: List.from(updatedWorkouts),
      muscleSets: Map.from(muscleSets),
      muscleStatus: Map.from(muscleStatus),
      muscleRecommendations: Map.from(muscleRecommendations),
    ));
  }

  FutureOr<void> _onToggleExerciseCompleted(ToggleExerciseCompleted event, Emitter<PlanWorkoutState> emit) {
    List<Post> updatedWorkouts = _plannedWorkouts
        .map((workout) => workout.copyWith(
      exercises: workout.exercises
          .map((exercise) => exercise.copyWith(
        name: exercise.name,
        muscleGroups: List.from(exercise.muscleGroups),
        sets: exercise.sets,
        isCompleted: exercise.isCompleted,
      ))
          .toList(),
    ))
        .toList();

    if (event.workoutIndex >= 0 && event.workoutIndex < updatedWorkouts.length) {
      final exercises = updatedWorkouts[event.workoutIndex].exercises;
      if (event.exerciseIndex >= 0 && event.exerciseIndex < exercises.length) {
        final exercise = exercises[event.exerciseIndex];
        final updatedExercises = List<ExerciseEntry>.from(exercises);
        updatedExercises[event.exerciseIndex] = exercise.copyWith(isCompleted: !exercise.isCompleted);
        updatedWorkouts[event.workoutIndex] = updatedWorkouts[event.workoutIndex].copyWith(exercises: updatedExercises);

        _plannedWorkouts.clear();
        _plannedWorkouts.addAll(updatedWorkouts);

        final muscleSets = MuscleAnalyzer.calculateMuscleSets(updatedWorkouts);
        final muscleStatus = <String, String>{};
        final muscleRecommendations = <String, String>{};

        for (var muscle in muscleSets.keys) {
          final sets = muscleSets[muscle]!;
          final pred = _workoutModel.predict(
            muscle: muscle,
            soFar: sets,
            toAdd: 0,
          );
          final labels = ['Undertrained', 'Balanced', 'Overtrained'];
          muscleStatus[muscle] = labels[pred];
          if (pred == 0) {
            muscleRecommendations[muscle] = 'Add ${10 - sets}-${20 - sets} sets';
          } else if (pred == 2) {
            muscleRecommendations[muscle] = 'Reduce by ${sets - 20} sets';
          } else {
            muscleRecommendations[muscle] = 'Balanced';
          }
        }

        emit(PlanWorkoutState(
          workouts: List.from(updatedWorkouts),
          muscleSets: Map.from(muscleSets),
          muscleStatus: Map.from(muscleStatus),
          muscleRecommendations: Map.from(muscleRecommendations),
        ));
      } else {
        print('Invalid exerciseIndex: ${event.exerciseIndex}');
      }
    } else {
      print('Invalid workoutIndex: ${event.workoutIndex}');
    }
  }

  FutureOr<void> _onClearPlan(ClearPlan event, Emitter<PlanWorkoutState> emit) {
    _plannedWorkouts.clear();
    emit(const PlanWorkoutState());
  }

  String updatedWorkoutsString(List<Post> workouts) {
    return workouts
        .asMap()
        .entries
        .map((entry) => 'Workout ${entry.key + 1}: ${entry.value.exercises.asMap().entries.map((e) => "${e.value.name}: ${e.value.isCompleted}").join(", ")}')
        .join(" | ");
  }

  @override
  Future<void> close() {
    _workoutModel.close();
    return super.close();
  }
}