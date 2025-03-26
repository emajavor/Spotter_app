import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter_app/models/post.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import '../bloc/post/post_bloc.dart';
import '../bloc/post/post_bloc.dart';
import '../bloc/post/post_bloc.dart';
import '../bloc/post/post_bloc.dart';
import '../bloc/post/post_bloc.dart';
import '../models/enums/intensity.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class AddPostScreen extends StatefulWidget {
  AddPostScreen();

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
  //Intensity? selectedIntensity;
}

class _AddPostScreenState extends State<AddPostScreen> {
  FirebaseStorage _storage = FirebaseStorage.instance;

  final exerciseController = TextEditingController();
  final workoutTypeController = TextEditingController();
  final locationController = TextEditingController();
  final playlistController = TextEditingController();
  Intensity? selectedIntensity = Intensity.Easy;

  final List<TextEditingController> exerciseControllers = [];

  late final List<String> _exercisesList = [];
  List<String> updatedExercises = [];
  late final String _workoutType;
  late String _newWorkoutType;
  late String _newLocation;
  late String _newPlaylist;
  late final XFile? pickedFile;
  late final DateTime? pickedDate;
  late final String _location;
  late final String _playlist;
  late final StreamController<bool> canEdit = true as StreamController<bool>;
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  TimeOfDay? _duration;
  TimeOfDay? selectedTime;
  DateTime? selectedDate;

  @override
  void dispose() {
    exerciseController.dispose();
    workoutTypeController.dispose();
    locationController.dispose();
    playlistController.dispose();

    for (var controller in exerciseControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // void addExerciseTextField() {
  //   final newExercise = exerciseController.text;
  //   if (newExercise.isNotEmpty) {
  //     _exercises.add(newExercise);
  //     exerciseController.clear();
  //   }
  // }

  // void addWorkoutTypeTextField() {
  //   _newWorkoutType = workoutTypeController.text;
  //
  //   if (_newWorkoutType.isNotEmpty) {
  //     _workoutType = _newWorkoutType;
  //     workoutTypeController.clear();
  //     canEdit.sink.add(false);
  //   }
  // }

  void editWorkoutTypeTextField() {
    canEdit.sink.add(true);
  }

  // void addLocationTextField() {
  //   _newLocation = locationController.text;
  //
  //   if (_newLocation.isNotEmpty) {
  //     _location = _newLocation;
  //     locationController.clear();
  //     canEdit.sink.add(false);
  //   }
  // }

  void editLocationTextField() {
    canEdit.sink.add(true);
  }

  // void addPlaylistTextField() {
  //   _newPlaylist = playlistController.text;
  //
  //   if (_newPlaylist.isNotEmpty) {
  //     _playlist = _newPlaylist;
  //     playlistController.clear();
  //     canEdit.sink.add(false);
  //   }
  // }

  void editPlaylistTextField() {
    canEdit.sink.add(true);
  }

  void addPhoto() async {
    pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    Reference reference = _storage.ref().child("images/");

    final storageRef = FirebaseStorage.instance.ref();

    if (pickedFile != null) {
      //_image = pickedFile;
    }
  }

  Future<void> addDateTime() async {
    pickedDate = await showOmniDateTimePicker(
      context:
          context, /*
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),*/
    );
    if (pickedDate != null) {}
  }

  void editDateTime() async {
    final newDate = await showOmniDateTimePicker(
      context: context,
    );

    if (newDate != null) {
      setState(() {
        selectedDate = newDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
      ),
      body: // BlocBuilder<PostBloc, PostState>(
          // bloc: BlocProvider.of<PostBloc>(context),
          // buildWhen: (prev, curr) => curr is UpdatedPost || curr is FetchedPosts,
          // builder: (context, state) {
          SingleChildScrollView(
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
                  BlocBuilder<PostBloc, PostState>(
                    bloc: BlocProvider.of<PostBloc>(context),
                    buildWhen: (prev, curr) =>
                    curr is AddedExercises || curr is EmptyExercises || curr is AddingExercise,
                    builder: (context, state) {
                      print("state in AddedScreen is $state");
                      if (state is AddedExercises) {
                        print(state);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // children: updatedExercises.map((exercise) {
                          //   return Padding(
                          //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          //     child: Text(exercise),
                          //   );
                          // }).toList(),
                          children: [
                            Text(state.addedExercises.toStringWithoutBrackets()),
                          ],
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
                        onPressed: () {

                          BlocProvider.of<PostBloc>(context).add(
                            AddExercises(
                              addedExercises: exerciseController.text,
                            ),
                          );
                          exerciseController.clear();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                          child: Text(
                            'ADD EXERCISE',
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
                  BlocBuilder<PostBloc, PostState>(
                    bloc: BlocProvider.of<PostBloc>(context),
                    buildWhen: (prev, curr) =>
                        curr is AddedWorkoutType || curr is AddingWorkoutType || curr is EmptyWorkoutType,
                    builder: (context, state) {
                      print("state in AddedScreen is $state");
                      if (state is AddedWorkoutType) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 15.0),
                              child: Text(
                                _newWorkoutType = workoutTypeController.text,
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 15.0),
                                child: ElevatedButton(
                                  onPressed: editWorkoutTypeTextField,
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.deepPurple),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 15.0),
                                    child: Text(
                                      'EDIT',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 16),
                              child: TextField(
                                controller: workoutTypeController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter a workout type',
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 15.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _newWorkoutType =
                                        workoutTypeController.text;
                                    BlocProvider.of<PostBloc>(context).add(
                                      AddWorkoutType(
                                        addedWorkoutType: _newWorkoutType,
                                      ),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.deepPurple),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 15.0),
                                    child: Text(
                                      'SAVE',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
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
                  BlocBuilder<PostBloc, PostState>(
                    bloc: BlocProvider.of<PostBloc>(context),
                    buildWhen: (prev, curr) =>
                        curr is AddedLocation || curr is AddingLocation || curr is EmptyLocation,
                    builder: (context, state) {
                      print("state in AddedScreen is $state");
                      if (state is AddedLocation) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 15.0),
                              child: Text(
                                _newLocation = locationController.text,
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 15.0),
                                child: ElevatedButton(
                                  onPressed: editLocationTextField,
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.deepPurple),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 15.0),
                                    child: Text(
                                      'EDIT',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 16),
                              child: TextField(
                                controller: locationController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter your location',
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 15.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _newLocation = locationController.text;
                                    BlocProvider.of<PostBloc>(context).add(
                                      AddLocation(
                                        addedLocation: _newLocation,
                                      ),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.deepPurple),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 15.0),
                                    child: Text(
                                      'SAVE',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
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
                      'Workout playlist:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  BlocBuilder<PostBloc, PostState>(
                    bloc: BlocProvider.of<PostBloc>(context),
                    buildWhen: (prev, curr) =>
                        curr is AddedPlaylist || curr is AddingPlaylist || curr is EmptyPlaylist,
                    builder: (context, state) {
                      print("state in AddedScreen is $state");
                      if (state is AddedPlaylist) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 15.0),
                                child: Text(
                                  _newPlaylist = playlistController.text,
                                ),
                              ),
                              onTap: () => launchUrl(Uri.parse(
                                  'https://open.spotify.com/track/0aw6RiTTT4LTpcoFy0kEkN?si=b9d91208e00144b3')),
                            ),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 15.0),
                                child: ElevatedButton(
                                  onPressed: editPlaylistTextField,
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.deepPurple),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 15.0),
                                    child: Text(
                                      'EDIT',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 16),
                              child: TextField(
                                controller: playlistController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Paste your playlist link',
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 15.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _newPlaylist = playlistController.text;
                                    BlocProvider.of<PostBloc>(context).add(
                                      AddPlaylist(
                                        addedPlaylist: _newPlaylist,
                                      ),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.deepPurple),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 15.0),
                                    child: Text(
                                      'SAVE',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
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
                          _buildIntensityItem(Intensity.Intermediate),
                          _buildIntensityItem(Intensity.Hard),

                        ],
                      ),
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
                          'Add photo:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                  ),
                  BlocBuilder<PostBloc, PostState>(
                    bloc: BlocProvider.of<PostBloc>(context),
                    buildWhen: (prev, curr) =>
                    curr is AddedImage || curr is EmptyImage || curr is AddingImage,
                    builder: (context, state) {
                      print("state in AddedScreen is $state");
                      if (state is AddedImage) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(
                            File(pickedFile.toString()),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          pickedFile = _picker.pickImage(source: ImageSource.gallery) as XFile?;

                          Reference reference = _storage.ref().child("images/");

                          final storageRef = FirebaseStorage.instance.ref();
                      },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                          child: Text(
                            'CHOOSE PHOTO',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),

                      ],
                    ),
                  ),
            //       Card(
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(15.0),
            //         ),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             const Padding(
            //               padding: EdgeInsets.only(top: 20, left: 10),
            //               child: Text(
            //                 'Add Duration:',
            //                 style: TextStyle(
            //                   fontWeight: FontWeight.bold,
            //                   fontSize: 20,
            //                 ),
            //               ),
            //             ),
            //
            //             StreamBuilder<DateTime?>(
            //               stream: _dateStreamController.stream,
            //               builder: (context, snapshot) {
            //                 if (snapshot.hasData) {
            //                   return Column(
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     children: [
            //                       Padding(
            //                         padding: EdgeInsets.only(top: 20, bottom: 20),
            //                         child: Column(
            //                           children: [
            //                             Padding(
            //                               padding: const EdgeInsets.all(10.0),
            //                               child: Text(
            //                                 'Selected Date: ${snapshot.data ?? 'No date selected'}',
            //                                 style: const TextStyle(fontSize: 16),
            //                               ),
            //                             ),
            //                             Center(
            //                               child: ElevatedButton(
            //                                 onPressed: editDateTime,
            //                                 style: ButtonStyle(
            //                                   backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
            //                                 ),
            //                                 child: const Padding(
            //                                   padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            //                                   child: Text(
            //                                     'EDIT DATE',
            //                                     style: TextStyle(fontSize: 16, color: Colors.white),
            //                                   ),
            //                                 ),
            //                               ),
            //                             )
            //                           ],
            //                         ),
            //                       ),
            //                     ],
            //                   );
            //                 } else {
            //                   return Center(
            //                     child: Padding(
            //                       padding: EdgeInsets.only(
            //                           top: 20.0, bottom: 15.0),
            //                       child: ElevatedButton(
            //                         onPressed: addDateTime,
            //                         style: ButtonStyle(
            //                           backgroundColor: MaterialStateProperty
            //                               .all<Color>(Colors.deepPurple),
            //                         ),
            //                         child: const Padding(
            //                           padding: EdgeInsets.symmetric(
            //                               horizontal: 20.0, vertical: 15.0),
            //                           child: Text(
            //                             'ADD TIME',
            //                             style: TextStyle(
            //                                 fontSize: 16, color: Colors.white),
            //                           ),
            //                         ),
            //                       ),
            //                     ),
            //                   );
            //                 }
            //               })
            //           ],
            //         ),
            //       ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: ElevatedButton(
                  onPressed: addPost,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.teal),
                  ),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    child: Text(
                      'ADD POST',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIntensityItem(Intensity intensity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(intensity.description),
        Radio<Intensity>(
          value: intensity,
          groupValue: selectedIntensity,
          onChanged: (Intensity? value) {
            setState(() {
              selectedIntensity = value;
            });
          },
        ),
      ],
    );
  }

  void addPost() {
    Post addedPost = Post(
        id: "aa",
        duration: pickedDate ?? DateTime.now(),
        location: _newLocation,
        photoURL: pickedFile.toString(),
        playlist: _newPlaylist,
        workout_type: _newWorkoutType,
        intensity: selectedIntensity ?? Intensity.Easy,
        exercises: _exercisesList);
    BlocProvider.of<PostBloc>(context).add(AddPost(addedPost: addedPost));
    // }
  }
}
