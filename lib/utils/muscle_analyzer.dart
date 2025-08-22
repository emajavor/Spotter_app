import 'package:spotter_app/models/post.dart';

class MuscleAnalyzer {
  static Map<String, int> calculateMuscleSets(List<Post> posts) { //Aggregates sets for each muscle group across all posts
    final Map<String, int> muscleMap = {};

    for (var post in posts) {
      for (var entry in post.exercises) {
        for (var muscle in entry.muscleGroups) {
          muscleMap[muscle] = (muscleMap[muscle] ?? 0) + entry.sets;
        }
      }
    }

    return muscleMap;
  }

  /*static Map<String, String> classifyMuscleLoad(Map<String, int> muscleSets) { //Classifies each muscle group and provides recommendations (e.g., "add 2-12 sets" when undertrained).
    final Map<String, String> statusMap = {};
    for (var muscle in muscleSets.keys) {
      final sets = muscleSets[muscle]!;
      if (sets < 10) {
        statusMap[muscle] = 'Undertrained (add ${10 - sets}-${20 - sets} sets)';
      } else if (sets > 20) {
        statusMap[muscle] = 'Overtrained (reduce by ${sets - 20} sets)';
      } else {
        statusMap[muscle] = 'Balanced';
      }
    }
    return statusMap;
  }*/
}