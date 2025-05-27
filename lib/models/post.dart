import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter_app/models/enums/intensity.dart';

class Post {
  final String id;
  final DateTime? duration;
  final String location;
  final String photoURL;
  final String playlist;
  final String workout_type;
  Intensity intensity;
  final List<String>? exercises;
  final String userId;
  final String username;

  @override
  String toString() {
    return 'Post(id: $id, userId: $userId, username: $username, workout_type: $workout_type, location: $location, duration: $duration, photoURL: $photoURL)';
  }

  Post({
    required this.id,
    required this.duration,
    required this.location,
    required this.photoURL,
    required this.playlist,
    required this.workout_type,
    required this.intensity,
    required this.exercises,
    required this.userId,
    required this.username,
  });

  Post copyWith({
    String? id,
    String? userId,
    String? username,
    String? workout_type,
    String? location,
    DateTime? duration,
    String? photoURL,
    String? playlist,
    Intensity? intensity,
    List<String>? exercises,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      workout_type: workout_type ?? this.workout_type,
      location: location ?? this.location,
      duration: duration ?? this.duration,
      photoURL: photoURL ?? this.photoURL,
      playlist: playlist ?? this.playlist,
      intensity: intensity ?? this.intensity,
      exercises: exercises ?? this.exercises,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    try {
      return Post(
        id: json['id'] as String? ?? '',
        duration: (json['duration'] is Timestamp)
            ? (json['duration'] as Timestamp).toDate()
            : json['duration'] != null
            ? DateTime.parse(json['duration'] as String)
            : null,
        location: json['location'] as String? ?? '',
        photoURL: json['photoURL'] as String? ?? '',
        playlist: json['playlist'] as String? ?? '',
        workout_type: json['workout_type'] as String? ?? '',
        intensity: _mapIntensity(json['intensity'] as String? ?? 'none'),
        exercises: (json['exercises'] as List<dynamic>?)?.cast<String>() ??
            (json['Exercises'] as List<dynamic>?)?.cast<String>() ??
            [],
        userId: json['userId'] as String? ?? '',
        username: json['username'] as String? ?? 'Unknown User',
      );
    } catch (e) {
      print("Error parsing post: $e");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'duration': duration != null ? Timestamp.fromDate(duration!) : null,
      'location': location,
      'photoURL': photoURL,
      'playlist': playlist,
      'workout_type': workout_type,
      'intensity': intensity.description,
      'exercises': exercises,
      'userId': userId,
      'username': username,
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

extension ListOutputExtension on List {
  String toStringWithoutBrackets() {
    return toString().replaceAll('[', '').replaceAll(']', '');
  }
}