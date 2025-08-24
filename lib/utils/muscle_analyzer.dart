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
}