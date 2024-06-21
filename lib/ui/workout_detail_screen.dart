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

  void _updateIntensity() async {
    Intensity newIntensity = Intensity.Intermediate;

    await widget.workoutPost.updateField(widget.workoutPost.id, newIntensity!.description.toString());
    setState(() {
      widget.workoutPost.intensity = newIntensity;
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Intensity updated to ${newIntensity!.description.toString()}'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Details'),
      ),
      body: Column(
        children: <Widget>[
          Card(child: IntensityCard(intensity: widget.workoutPost.intensity,)),
          Card(child: IntensityCard(text: 'Exercises: ${widget.workoutPost.exercises.toStringWithoutBrackets()}')),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
                ),
                onPressed: _updateIntensity,
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



