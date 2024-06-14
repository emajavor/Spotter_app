import 'package:flutter/material.dart';
import 'package:spotter_app/ui/widgets/intensity_card.dart';
import '../models/enums/intensity.dart';
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
        children: <Widget>[
          Card(child: IntensityCard(intensity: widget.workoutPost.intensity,)),
          Card(child: IntensityCard(text: 'Exercises: ${widget.workoutPost.exercises}')),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
                ),
                onPressed: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  child: Text(
                    'UPDATE',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



