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
  Exercise(name: 'Crunch', muscleGroups: ['Abs']),
  Exercise(name: 'Plank', muscleGroups: ['Abs']),
  Exercise(name: 'Hanging Leg Raise', muscleGroups: ['Abs']),
  Exercise(name: 'Russian Twist', muscleGroups: ['Abs', 'Obliques']),
  Exercise(name: 'Cable Crunch', muscleGroups: ['Abs']),
  Exercise(name: 'Mountain Climbers', muscleGroups: ['Abs']),
  Exercise(name: 'Bicycle Crunch', muscleGroups: ['Abs', 'Obliques']),
  Exercise(name: 'Side Plank', muscleGroups: ['Abs', 'Obliques']),
  Exercise(name: 'Toe Touch', muscleGroups: ['Abs']),
  Exercise(name: 'Ab Rollout', muscleGroups: ['Abs']),
  Exercise(name: 'Shoulder Press', muscleGroups: ['Shoulders']),
  Exercise(name: 'Lateral Raise', muscleGroups: ['Shoulders']),
  Exercise(name: 'Pull-Up', muscleGroups: ['Back', 'Biceps']),
  Exercise(name: 'Chest Fly', muscleGroups: ['Chest']),
  Exercise(name: 'Dumbbell Row', muscleGroups: ['Back']),
  Exercise(name: 'Hip Thrust', muscleGroups: ['Glutes', 'Hamstrings']),
  Exercise(name: 'Leg Curl', muscleGroups: ['Hamstrings']),
  Exercise(name: 'Leg Extension', muscleGroups: ['Quads']),
  Exercise(name: 'Arnold Press', muscleGroups: ['Shoulders']),
  Exercise(name: 'Face Pull', muscleGroups: ['Rear Delts', 'Traps']),
];