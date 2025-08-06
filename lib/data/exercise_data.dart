class Exercise {
  final String name;
  final String muscleGroup;

  Exercise({required this.name, required this.muscleGroup});
}

final List<Exercise> allExercises = [
  Exercise(name: 'Chest Press', muscleGroup: 'Chest'),
  Exercise(name: 'Bench Press', muscleGroup: 'Chest'),
  Exercise(name: 'Incline Dumbbell Press', muscleGroup: 'Chest'),
  Exercise(name: 'Lat Pulldown', muscleGroup: 'Back'),
  Exercise(name: 'Deadlift', muscleGroup: 'Back'),
  Exercise(name: 'Squat', muscleGroup: 'Legs'),
  Exercise(name: 'Leg Press', muscleGroup: 'Legs'),
  Exercise(name: 'Bicep Curl', muscleGroup: 'Biceps'),
  Exercise(name: 'Tricep Extension', muscleGroup: 'Triceps'),
  // Add more as needed
];