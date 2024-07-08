import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter_app/bloc/post/post_bloc.dart';
import 'package:spotter_app/repository/firebase_repo_implementation.dart';
import 'package:spotter_app/ui/widgets/intensity_card.dart';
import '../models/enums/intensity.dart';
import '../models/post.dart';

class WorkoutDetailScreen extends StatefulWidget {
  Post workoutPost;
  //Intensity currentIntensity = Intensity.none;
  WorkoutDetailScreen({required this.workoutPost});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  void _updateIntensity(Intensity? newIntensity) async {
    BlocProvider.of<PostBloc>(context).add(UpdatePost(
        id: widget.workoutPost.id,
        newIntensity: newIntensity!
      )//koristim BlocProvider da pristupim PostBlocu
    );
    widget.workoutPost.intensity = newIntensity; // pamti vrijednost i nakon popanja prozorcica
    Navigator.of(context).pop();
    print("This is widget.workoutpost.intensity: ${widget.workoutPost.intensity}");

  }
  Widget _selectIntensityOption(Intensity intensity, String label) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Radio<Intensity>(
          value: intensity,
          groupValue: widget.workoutPost.intensity,
          onChanged: (Intensity? value) {
            _updateIntensity(value);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return BlocListener<PostBloc, PostState>(
      bloc: BlocProvider.of<PostBloc>(context),
      listenWhen: (prev, curr) =>
          curr is UpdatedPost || curr is FailedUpdatedPost || curr is FetchedPost,
      listener: (context, state) {
        if (state is UpdatedPost) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Intensity updated to ${state.updatedPost.intensity.description}')));
        }
        else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Intensity not updated')));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Workout Details'),
        ),
        body: BlocBuilder<PostBloc, PostState>(
          bloc: BlocProvider.of<PostBloc>(context),
          buildWhen: (prev, curr) => curr is UpdatedPost || curr is FetchedPosts,
          builder: (context, state) {
            print("State in DetailsScreen is: $state");
            Intensity currentIntensity;
            if (state is UpdatedPost) {
              currentIntensity = state.updatedPost.intensity;
              print("Post is: ${state.updatedPost.id}");

              print("state.updatedPost.intensity is ${state.updatedPost.intensity}");
            }
            currentIntensity = widget.workoutPost.intensity;//zastoooooooooooooooooo
            print("current intensity is ${currentIntensity}");
            print("widget.workoutPost.intensity is ${widget.workoutPost.intensity}");
            if (state is FetchedPosts || state is UpdatedPost) {
              return Column(
                children: <Widget>[
                  Card(
                      child: IntensityCard(
                      intensity: currentIntensity,
                  )),
                  Card(
                      child: IntensityCard(
                          text:
                              'Exercises: ${widget.workoutPost.exercises.toStringWithoutBrackets()}')),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.teal),
                        ),
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Update the Intensity'),
                            content: const Text(
                                'Select the Intensity of your workout'),
                            actions: <Widget>[
                              _selectIntensityOption(Intensity.Easy, 'Easy'),
                              _selectIntensityOption(Intensity.Intermediate, 'Intermediate'),
                              _selectIntensityOption(Intensity.Hard, 'Hard'),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                          child: Text(
                            'UPDATE',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is UpdatingPost) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

}


