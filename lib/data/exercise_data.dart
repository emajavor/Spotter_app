class Exercise {
  final String name;
  final List<String> muscleGroups;
  Exercise({required this.name, required this.muscleGroups});
}

final List<Exercise> allExercises = [
  Exercise(name: 'Chest Press', muscleGroups: ['Chest']),
  Exercise(name: 'Bench Press', muscleGroups: ['Chest']),
  Exercise(name: 'Incline Dumbbell Press', muscleGroups: ['Chest']),
  Exercise(name: 'Lat Pulldown', muscleGroups: ['Back']),
  Exercise(name: 'Romanian Deadlift', muscleGroups: ['Back', 'Hamstrings', 'Glutes']),
  Exercise(name: 'Squat', muscleGroups: ['Quads', 'Hamstrings', 'Glutes']),
  Exercise(name: 'Leg Press', muscleGroups: ['Quads', 'Hamstrings']),
  Exercise(name: 'Bicep Curl', muscleGroups: ['Biceps']),
  Exercise(name: 'Tricep Extension', muscleGroups: ['Triceps']),
  Exercise(name: 'Calves Extension', muscleGroups: ['Calves']),
];