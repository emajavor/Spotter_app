import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter_app/bloc/post/post_bloc.dart';
import 'package:spotter_app/ui/widgets/intensity_card.dart';
import '../models/enums/intensity.dart';
import '../models/post.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Post workoutPost;
  const WorkoutDetailScreen({super.key, required this.workoutPost});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details'),
      ),
      body: Column(
        children: <Widget>[
          IntensityCard(
            intensity: widget.workoutPost.intensity,
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.93,
              height: MediaQuery.of(context).size.height * 0.15,
              child: Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.sizeOf(context).width * 0.05,
                  top: MediaQuery.sizeOf(context).width * 0.05,
                ),
                child: Text(
                  'Exercises:\n${widget.workoutPost.exercises.map((exercise) => exercise.toDisplayString()).join('\n')}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}