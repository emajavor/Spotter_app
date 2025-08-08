import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter_app/models/enums/intensity.dart';

class ExerciseEntry {
  final String name;
  final List<String> muscleGroups;
  final int sets;

  const ExerciseEntry({
    required this.name,
    required this.muscleGroups,
    required this.sets,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'muscleGroups': muscleGroups,
    'sets': sets,
  };

  factory ExerciseEntry.fromJson(Map<String, dynamic> json) => ExerciseEntry(
    name: json['name'] as String? ?? '',
    muscleGroups: (json['muscleGroups'] as List<dynamic>?)?.cast<String>() ?? [],
    sets: json['sets'] as int? ?? 0,
  );

  String toDisplayString() => '$name (${muscleGroups.join(", ")}, $sets sets)';
}

class Comment {
  final String userId;
  final String username;
  final String text;
  final Timestamp timestamp;

  Comment({
    required this.userId,
    required this.username,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? 'Unknown User',
      text: json['text'] as String? ?? '',
      timestamp: json['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'text': text,
      'timestamp': timestamp,
    };
  }
}

class Post {
  final String id;
  final DateTime? date;
  final String location;
  final String photoURL;
  final String playlist;
  final String workout_type;
  Intensity intensity;
  final List<ExerciseEntry> exercises;
  final String userId;
  final String username;
  final List<String> likes; // Added: List of user IDs who liked the post
  final List<Comment> comments; // Added: List of comments  @override
  String toString() {
    return 'Post(id: $id, userId: $userId, username: $username, workout_type: $workout_type, location: $location, date: $date, photoURL: $photoURL, likes: ${likes.length}, comments: ${comments.length})';
  }

  Post({
    required this.id,
    required this.date,
    required this.location,
    required this.photoURL,
    required this.playlist,
    required this.workout_type,
    required this.intensity,
    required this.exercises,
    required this.userId,
    required this.username,
    this.likes = const [], // Default to empty list
    this.comments = const [], // Default to empty list
  });

  Post copyWith({
    String? id,
    String? userId,
    String? username,
    String? workout_type,
    String? location,
    DateTime? date,
    String? photoURL,
    String? playlist,
    Intensity? intensity,
    List<ExerciseEntry>? exercises,
    List<String>? likes,
    List<Comment>? comments,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      workout_type: workout_type ?? this.workout_type,
      location: location ?? this.location,
      date: date ?? this.date,
      photoURL: photoURL ?? this.photoURL,
      playlist: playlist ?? this.playlist,
      intensity: intensity ?? this.intensity,
      exercises: exercises ?? this.exercises,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    try {
      return Post(
        id: json['id'] as String? ?? '',
        date: json['date'] is Timestamp
            ? (json['date'] as Timestamp).toDate()
            : (json['duration'] is String
            ? DateTime.parse(json['duration'] as String)
            : null),
        location: json['location'] as String? ?? '',
        photoURL: json['photoURL'] as String? ?? '',
        playlist: json['playlist'] as String? ?? '',
        workout_type: json['workout_type'] as String? ?? '',
        intensity: _mapIntensity(json['intensity'] as String? ?? 'none'),
        exercises: (json['exercises'] as List<dynamic>?)
            ?.map((e) => ExerciseEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
            [],
        userId: json['userId'] as String? ?? '',
        username: json['username'] as String? ?? 'Unknown User',
        likes: (json['likes'] as List<dynamic>?)?.cast<String>() ?? [],
        comments: (json['comments'] as List<dynamic>?)
            ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
            .toList() ??
            [],
      );
    } catch (e) {
      print("Error parsing post: $e");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'location': location,
      'photoURL': photoURL,
      'playlist': playlist,
      'workout_type': workout_type,
      'intensity': intensity.description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'userId': userId,
      'username': username,
      'likes': likes,
      'comments': comments.map((e) => e.toJson()).toList(),
    };
  }

  Map<String, dynamic> toMap() => toJson();

  static Intensity _mapIntensity(String intensityString) {
    switch (intensityString.toLowerCase()) {
      case 'easy':
        return Intensity.Easy;
      case 'intermediate':
        return Intensity.Intermediate;
      case 'hard':
        return Intensity.Hard;
      case 'none':
      default:
        return Intensity.none;
    }
  }
}

extension IntensityExtension on Intensity {
  String get description {
    switch (this) {
      case Intensity.Easy:
        return 'Easy';
      case Intensity.Intermediate:
        return 'Intermediate';
      case Intensity.Hard:
        return 'Hard';
      case Intensity.none:
        return 'none';
    }
  }
}
