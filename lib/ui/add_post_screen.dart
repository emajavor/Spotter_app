import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../bloc/post/post_bloc.dart';
import '../models/enums/intensity.dart';

class AddPostScreen extends StatefulWidget {
  AddPostScreen();

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
  Intensity? selectedIntensity;
}

class _AddPostScreenState extends State<AddPostScreen> {
  final exerciseController = TextEditingController();
  final workoutTypeController = TextEditingController();
  final locationController = TextEditingController();
  Intensity? selectedIntensity = Intensity.Easy;

  final List<TextEditingController> exerciseControllers = [];
  final StreamController<List<String>> _exerciseStreamController = StreamController<List<String>>.broadcast();
  late final StreamController<String> _workoutTypeStreamController = StreamController<String>.broadcast();
  final List<String> _exercises = [];
  late final String _workoutType;

  @override
  void dispose() {

    exerciseController.dispose();
    workoutTypeController.dispose();
    locationController.dispose();

    for (var controller in exerciseControllers) {
      controller.dispose();
    }
    _exerciseStreamController.close();
    super.dispose();
  }

  void addExerciseTextField() {
    final newExercise = exerciseController.text;
    if (newExercise.isNotEmpty) {
      _exercises.add(newExercise);
      _exerciseStreamController.sink.add(_exercises);
      exerciseController.clear();
    }
  }
  void addWorkoutTypeTextField() {
    final newWorkoutType = workoutTypeController.text;
    if (newWorkoutType.isNotEmpty) {
      _workoutType = newWorkoutType;
      _workoutTypeStreamController.sink.add(newWorkoutType);
      workoutTypeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      bloc: BlocProvider.of<PostBloc>(context),
      listenWhen: (prev, curr) =>
      curr is AddedPost || curr is FailedAddedPost || curr is FetchedPost,
      listener: (context, state) {
        if (state is AddedPost) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Post is added')));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to add post')));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Post'),
        ),
        body: BlocBuilder<PostBloc, PostState>(
          bloc: BlocProvider.of<PostBloc>(context),
          buildWhen: (prev, curr) => curr is UpdatedPost || curr is FetchedPosts,
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 20, left: 10),
                          child: Text(
                            textAlign: TextAlign.left,
                            'Add exercises:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        StreamBuilder<List<String>>(
                          stream: _exerciseStreamController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Column(
                                children: snapshot.data!.map((exercise) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    child: Text(exercise),
                                  );
                                }).toList(),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child: TextField(
                            controller: exerciseController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter an exercise',
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 15.0),
                            child: ElevatedButton(
                              onPressed: addExerciseTextField,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 15.0),
                                child: Text(
                                  'ADD EXERCISE',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 20, left: 10),
                          child: Text(
                            textAlign: TextAlign.left,
                            'Workout type:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        StreamBuilder<String>(
                          stream: _workoutTypeStreamController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Text(snapshot.data!),
                              );
                            } else {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                child: TextField(
                                  controller: workoutTypeController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter a workout type',
                                  ),
                                ),
                              );
                            }
                          },
                        ),

                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 15.0),
                            child: ElevatedButton(
                              onPressed: addWorkoutTypeTextField,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 15.0),
                                child: Text(
                                  'SAVE',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 20, left: 10),
                          child: Text(
                            textAlign: TextAlign.left,
                            'Location:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child: TextField(
                            controller: locationController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter a location',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Easy'),
                              Radio<Intensity>(
                                value: Intensity.Easy,
                                groupValue: selectedIntensity,
                                onChanged: (Intensity? value) {
                                  setState(() {
                                    selectedIntensity = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Intermediate'),
                              Radio<Intensity>(
                                value: Intensity.Intermediate,
                                groupValue: selectedIntensity,
                                onChanged: (Intensity? value) {
                                  setState(() {
                                    selectedIntensity = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Hard'),
                              Radio<Intensity>(
                                value: Intensity.Hard,
                                groupValue: selectedIntensity,
                                onChanged: (Intensity? value) {
                                  setState(() {
                                    selectedIntensity = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
