import 'package:flutter/material.dart';

import '../models/post.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Post workoutPost;

  WorkoutDetailScreen({required this.workoutPost});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Details'),
      ),
      body: Column(
        children: [
              Text(
                'Intensity: ${widget.workoutPost.intensity}',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.left,

               ),
              Text(
                'Exercises: ${widget.workoutPost.exercises}',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.left,

               ),
               Center(
                 child: TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  onPressed: () { },
                  child: Text('UPDATE'),

                  ),
               ),
        ],
      ),
    );
  }
}
