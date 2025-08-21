import 'package:flutter/material.dart';
import 'package:spotter_app/ui/widgets/intensity_card.dart';
import '../models/post.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Post workoutPost;

  const WorkoutDetailScreen({super.key, required this.workoutPost});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // tamna pozadina
      appBar: AppBar(
        title: const Text('Workout Details'),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            IntensityCard(
              intensity: workoutPost.intensity,
            ),
            const SizedBox(height: 20),
            _ExercisesCard(exercises: workoutPost.exercises),
          ],
        ),
      ),
    );
  }
}

class _ExercisesCard extends StatelessWidget {
  final List exercises;

  const _ExercisesCard({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exercises',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...exercises.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              e.toDisplayString(),
              style: TextStyle(color: Colors.grey[300], fontSize: 16),
            ),
          )),
        ],
      ),
    );
  }
}
