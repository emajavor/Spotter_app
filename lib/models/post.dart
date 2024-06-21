import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:spotter_app/models/enums/intensity.dart';

class Post {
  final String id;
  final DateTime duration;
  final String location;
  final String photoURL;
  final String playlist;
  final String workout_type;
  Intensity intensity;
  final List<String> exercises;

  Post({required this.id, required this.duration, required this.location, required this.photoURL, required this.playlist, required this.workout_type, required this.intensity, required this.exercises,});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      duration: json["duration"].toDate(),
      location: json['location'] as String,
      photoURL: json['photoURL'] as String,
      playlist: json['playlist'] as String,
      workout_type: json['workout_type'] as String,
      intensity: _mapIntensity(json['intensity'] as String),
      exercises:  List.castFrom(json['Exercises']) ,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'duration': duration,
      'location': location,
      'photoURL': photoURL,
      'playlist': playlist,
      'workout_type': workout_type,
      'intensity': intensity.toString().split('.').last,
      'exercises': exercises,
    };
  }


  Post.fromMap(Map<String, dynamic> data) :
        id = data['id'],
        duration = data['duration'],
        location = data['location'],
        photoURL = data['photoURL'],
        playlist = data['playlist'],
        workout_type = data['workout_type'],
        exercises = data['Exercises'],
        intensity = data['intensity'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'duration': duration,
      'location': location,
      'playlist': playlist,
      'workout_type': workout_type,
      'intensity': intensity,
      'exercises': exercises,
      'photoURL': photoURL
    };
  }



  static Intensity _mapIntensity(String intensityString) {
    Intensity intensity = Intensity.none;

    switch(intensityString){
      case "Easy":
        intensity = Intensity.Easy;
    }
    switch(intensityString){
      case "Intermediate":
        intensity = Intensity.Intermediate;
    }
    switch(intensityString){
      case "Hard":
        intensity = Intensity.Hard;
    }
    return intensity;
  }

  Future<void> updateField(String documentId, String newIntensity) async {
    print('documentId : $documentId, newIntensity: $newIntensity');
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(documentId)
          .update({'intensity': newIntensity});
      print('Document successfully updated!');
    } catch (e) {
      print('Error updating document: $e');
    }
  }

}

extension ListOutputExtension on List {
  String toStringWithoutBrackets() {
    return toString().replaceAll('[', '').replaceAll(']', '');
  }

}

