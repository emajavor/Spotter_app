Map<String, int> calculateMuscleSets(List<Map<String, dynamic>> exercises) {
  final Map<String, int> muscleMap = {};

  for (var entry in exercises) {
    final String muscle = entry['muscleGroup'];
    final int sets = entry['sets'];

    if (!muscleMap.containsKey(muscle)) {
      muscleMap[muscle] = sets;
    } else {
      muscleMap[muscle] = muscleMap[muscle]! + sets;
    }
  }

  return muscleMap;
}

String classifyMuscleLoad(int sets) {
  if (sets < 10) return "Undertrained";
  if (sets > 20) return "Overtrained";
  return "Balanced";
}