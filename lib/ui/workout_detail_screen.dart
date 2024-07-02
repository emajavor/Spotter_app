import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter_app/bloc/post/post_bloc.dart';
import 'package:spotter_app/repository/firebase_repo_implementation.dart';
import 'package:spotter_app/ui/widgets/intensity_card.dart';
import '../models/enums/intensity.dart';
import '../models/post.dart';

class WorkoutDetailScreen extends StatefulWidget {
  Post workoutPost;

  WorkoutDetailScreen({required this.workoutPost});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {

  void _updateIntensity() async {
    Intensity newIntensity = Intensity.Easy;

    BlocProvider.of<PostBloc>(context).add(UpdatePost(id: widget.workoutPost.id, newIntensity: newIntensity)); //koristim BlocProvider da pristupim PostBlocu

    
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      bloc: BlocProvider.of<PostBloc>(context),
      listenWhen: (prev, curr) => curr is UpdatedPost || curr is FailedUpdatedPost,
    listener: (context, state) {

    if(state is UpdatedPost){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Intensity updated to ${Intensity.Hard.description}'))
      );
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Intensity not updated'))
      );
    }
  },
  child: Scaffold(
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
    ),
);
  }
}



