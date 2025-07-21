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
  void _updateIntensity(Intensity? newIntensity) async {
    BlocProvider.of<PostBloc>(context).add(
      UpdatePost(id: widget.workoutPost.id.toString(), newIntensity: newIntensity!),
    );
    widget.workoutPost.intensity = newIntensity;
    Navigator.of(context).pop();
  }

  Widget _buildIntensityOption(Intensity intensity, String label) {
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
          curr is UpdatedPost ||
          curr is FailedUpdatedPost ||
          curr is FetchedPost,
      listener: (context, state) {
        if (state is UpdatedPost) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Intensity updated to ${state.updatedPost.intensity.description}')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Intensity not updated')));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout Details'),
        ),
        body: BlocBuilder<PostBloc, PostState>(
          bloc: BlocProvider.of<PostBloc>(context),
          buildWhen: (prev, curr) =>
              curr is UpdatedPost || curr is FetchedPosts,
          builder: (context, state) {
            Intensity currentIntensity;
            if (state is UpdatedPost) {
              currentIntensity = state.updatedPost.intensity;
            }
            currentIntensity = widget.workoutPost.intensity;
            if (state is FetchedPosts || state is UpdatedPost) {
              return Column(
                children: <Widget>[
                  IntensityCard(
                    intensity: currentIntensity,
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
                              top: MediaQuery.sizeOf(context).width * 0.05
                          ),
                          child: Text(
                              'Exercises:\n${widget.workoutPost.exercises?.toStringWithoutBrackets()}',
                              style: const TextStyle(fontSize: 18))),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor:
                              WidgetStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.teal),
                        ),
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Update the Intensity'),
                            content: const Text(
                                'Select the Intensity of your workout'),
                            actions: <Widget>[
                              _buildIntensityOption(Intensity.Easy, 'Easy'),
                              _buildIntensityOption(
                                  Intensity.Intermediate, 'Intermediate'),
                              _buildIntensityOption(Intensity.Hard, 'Hard'),
                            ],
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
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
