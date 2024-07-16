import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
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
  final exerciseController = TextEditingController();
  final workoutTypeController = TextEditingController();
  final locationController = TextEditingController();
  final playlistController = TextEditingController();
  Intensity? selectedIntensity = Intensity.Easy;

  final List<TextEditingController> exerciseControllers = [];
  final StreamController<List<String>> _exerciseStreamController = StreamController<List<String>>.broadcast();
  late final StreamController<String> _workoutTypeStreamController = StreamController<String>.broadcast();
  late final StreamController<String> _locationStreamController = StreamController<String>.broadcast();
  late final StreamController<String> _playlistStreamController = StreamController<String>.broadcast();
  late final StreamController<XFile?> _imageStreamController = StreamController<XFile?>.broadcast();
  late final StreamController<TimeOfDay?> _timeStreamController = StreamController<TimeOfDay?>.broadcast();
  late final StreamController<DateTime?> _dateStreamController = StreamController<DateTime?>.broadcast();
  final List<String> _exercises = [];
  late final String _workoutType;
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
    _exerciseStreamController.close();
    _workoutTypeStreamController.close();
    _locationStreamController.close();
    _playlistStreamController.close();
    _imageStreamController.close();
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
      canEdit.sink.add(false);
    }
  }
  void editWorkoutTypeTextField(){
    canEdit.sink.add(true);
  }
  void addLocationTextField() {
    final newLocation = locationController.text;

    if (newLocation.isNotEmpty) {
      _location = newLocation;
      _locationStreamController.sink.add(newLocation);
      locationController.clear();
      canEdit.sink.add(false);
    }
  }
  void editLocationTextField(){
    canEdit.sink.add(true);
  }

  void addPlaylistTextField() {
    final newPlaylist = playlistController.text;

    if (newPlaylist.isNotEmpty) {
      _playlist = newPlaylist;
      _playlistStreamController.sink.add(newPlaylist);
      playlistController.clear();
      canEdit.sink.add(false);
    }
  }
  void editPlaylistTextField(){
    canEdit.sink.add(true);
  }
  void addPhoto() async{
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      //_image = pickedFile;
      _imageStreamController.sink.add(pickedFile);
    }
  }

  Future<void> addDateTime() async{
    final pickedDate = await showOmniDateTimePicker(
      context: context,/*
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),*/
    );
    if (pickedDate != null) {
      _dateStreamController.sink.add(pickedDate);
    }
  }

  void editDateTime() async {
    DateTime? newDate = await showOmniDateTimePicker(
      context: context,
      // initialDate: selectedDate ?? DateTime.now(),
      // firstDate: DateTime(2000),
      // lastDate: DateTime(2100),
    );

    if (newDate != null) {
      setState(() {
        selectedDate = newDate;
      });
      _dateStreamController.add(newDate);
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
                        StreamBuilder<String>(
                          stream: _workoutTypeStreamController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                  child: Text(
                                      snapshot.data!,),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 15.0),
                                      child: ElevatedButton(
                                        onPressed: editWorkoutTypeTextField,
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                          child: Text(
                                            'EDIT',
                                            style: TextStyle(fontSize: 16, color: Colors.white),
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
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                                        onPressed: addWorkoutTypeTextField,
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                          child: Text(
                                            'SAVE',
                                            style: TextStyle(fontSize: 16, color: Colors.white),
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
                            'Location:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        StreamBuilder<String>(
                          stream: _locationStreamController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                  child: Text(
                                      snapshot.data!,),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 15.0),
                                      child: ElevatedButton(
                                        onPressed: editLocationTextField,
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                          child: Text(
                                            'EDIT LOCATION',
                                            style: TextStyle(fontSize: 16, color: Colors.white),
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
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                                        onPressed: addLocationTextField,
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                          child: Text(
                                            'SAVE',
                                            style: TextStyle(fontSize: 16, color: Colors.white),
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
                        StreamBuilder<String>(
                          stream: _playlistStreamController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                    child: Text(
                                        snapshot.data!,),
                                    ),
                                    onTap: () => launchUrl(Uri.parse('https://open.spotify.com/track/0aw6RiTTT4LTpcoFy0kEkN?si=b9d91208e00144b3')),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 15.0),
                                      child: ElevatedButton(
                                        onPressed: editPlaylistTextField,
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                          child: Text(
                                            'EDIT',
                                            style: TextStyle(fontSize: 16, color: Colors.white),
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
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                                        onPressed: addPlaylistTextField,
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                          child: Text(
                                            'SAVE',
                                            style: TextStyle(fontSize: 16, color: Colors.white),
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
                  StreamBuilder<XFile?>(
                    stream: _imageStreamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(
                            File(snapshot.data!.path),
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
                        onPressed: addPhoto,
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
                            'Add Duration:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),

                        StreamBuilder<DateTime?>(
                          stream: _dateStreamController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 20, bottom: 20),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                            'Selected Date: ${snapshot.data ?? 'No date selected'}',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: editDateTime,
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                              child: Text(
                                                'EDIT DATE',
                                                style: TextStyle(fontSize: 16, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 20.0, bottom: 15.0),
                                  child: ElevatedButton(
                                    onPressed: addDateTime,
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors.deepPurple),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 15.0),
                                      child: Text(
                                        'ADD TIME',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          })
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: ElevatedButton(
                        onPressed: editLocationTextField, //TODO implement addPost
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
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
            );
          },
        ),
      ),
    );
  }
}
