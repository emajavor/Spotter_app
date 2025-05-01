import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spotter_app/models/post.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import '../bloc/post/post_bloc.dart';
import '../models/enums/intensity.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
  //Intensity? selectedIntensity;
}

class _AddPostScreenState extends State<AddPostScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final exerciseController = TextEditingController();
  final workoutTypeController = TextEditingController();
  final locationController = TextEditingController();
  final playlistController = TextEditingController();
  Intensity? selectedIntensity = Intensity.Easy;

  final List<TextEditingController> exerciseControllers = [];

  final List<String> _exercisesList = [];
  List<String> updatedExercises = [];
  late final String _workoutType;
  String? _newWorkoutType;
  String? _newLocation;
  String? _newPlaylist;
  late final DateTime? pickedDate;
  late final String _location;
  late final String _playlist;
  late final StreamController<bool> canEdit = true as StreamController<bool>;
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  TimeOfDay? _duration;
  TimeOfDay? selectedTime;
  DateTime? selectedDate;
//////////////////////////////////////////////////////////////
  get pickedFile => null;
////////////////////////////////////////////
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
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);//returns Future<XFile?> and we wait for the result
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
        //we send AddImage(addedImage: pickedFile) in PostBloc, which matches with the definition of AddImage events.
        context.read<PostBloc>().add(AddImage(addedImage: pickedFile));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Storage permission denied',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
        title: const Text('Add Post'),
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
              color: Theme.of(context).colorScheme.surface,
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 10),
                    child: Text(
                      'Add exercises:',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextField(
                      controller: exerciseController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Enter an exercise',
                        prefixIcon: Icon(
                          Icons.dashboard_customize,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<PostBloc>(context).add(
                            AddExercises(
                              addedExercises: exerciseController.text,
                            ),
                          );
                          exerciseController.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'ADD EXERCISE',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
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
              color: Theme.of(context).colorScheme.surface,
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(
                    padding: const EdgeInsets.only(top: 20, left: 10),
                    child: Text(
                      'Workout type:',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
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
                        _newWorkoutType = state.addedWorkoutType; // Spremi vrijednost iz Bloca
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 15.0),
                              child: Text(
                                _newWorkoutType ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    workoutTypeController.text = _newWorkoutType ?? ''; // Postavi spremljenu vrijednost u TextField
                                    context.read<PostBloc>().add(const AddWorkoutType(addedWorkoutType: '')); // Resetiraj za edit
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                  ),
                                  child: Text(
                                    'EDIT',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 16),
                              child: TextField(
                                controller: workoutTypeController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  hintText: 'Enter a workout type',
                                  prefixIcon: Icon(
                                    Icons.fitness_center,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _newWorkoutType = workoutTypeController.text.trim();
                                    if (_newWorkoutType?.isNotEmpty ?? false) {
                                      context.read<PostBloc>().add(
                                        AddWorkoutType(addedWorkoutType: _newWorkoutType!),
                                      );
                                      workoutTypeController.clear();
                                    } else {
                                      context.read<PostBloc>().add(const AddWorkoutType(addedWorkoutType: ''));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                  ),
                                  child: Text(
                                    'SAVE',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
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
              color: Theme.of(context).colorScheme.surface,
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 10),
                    child: Text(
                      'Location:',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
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
                        _newLocation = state.addedLocation; // Spremi vrijednost iz Bloca
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 15.0),
                              child: Text(
                                _newLocation ?? '',
                                style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: ElevatedButton(
                                  onPressed: (){
                                    context.read<PostBloc>().add(const AddLocation(addedLocation: '')); // Resetiraj za edit
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                  ),
                                  child: Text(
                                    'EDIT',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 16),
                              child: TextField(
                                controller: locationController,
                                decoration:  InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  hintText: 'Enter your location',
                                  prefixIcon: Icon(
                                    Icons.location_on,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _newLocation = locationController.text;
                                    if (_newLocation?.isNotEmpty ?? false) {
                                      context.read<PostBloc>().add(AddLocation(addedLocation: _newLocation!));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                  ),
                                  child: Text(
                                    'SAVE',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
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
              color: Theme.of(context).colorScheme.surface,
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 10),
                    child: Text(
                      'Workout playlist:',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
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
                        _newPlaylist = state.addedPlaylist; // Spremi vrijednost iz Bloca
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 15.0),
                                child: Text(
                                  _newPlaylist ?? '',
                                  style: GoogleFonts.poppins(
                                    color: Theme.of(context).colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              onTap: () async {
                                final url = Uri.parse(_newPlaylist ?? '');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.read<PostBloc>().add(const AddPlaylist(addedPlaylist: '')); // Resetiraj za edit
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                  ),
                                  child: Text('EDIT',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 16),
                              child: TextField(
                                controller: playlistController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  hintText: 'Paste your playlist link',
                                  prefixIcon: Icon(
                                    Icons.music_note,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _newPlaylist = playlistController.text;
                                    if (_newPlaylist?.isNotEmpty ?? false) {
                                      context.read<PostBloc>().add(AddPlaylist(addedPlaylist: _newPlaylist!));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                  ),
                                  child: Text('SAVE',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
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
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Easy',
                                style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface),
                              ),
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
                   Padding(
                      padding: const EdgeInsets.only(top: 20, left: 10),
                      child: Text(
                          textAlign: TextAlign.left,
                          'Add photo:',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                  ),
                  BlocBuilder<PostBloc, PostState>(
                    bloc: BlocProvider.of<PostBloc>(context),
                    buildWhen: (prev, curr) =>
                    curr is AddedImage || curr is EmptyImage || curr is AddingImage,
                    builder: (context, state) {
                      print("state in AddedScreen is $state");
                      if (state is AddedImage && _image != null) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_image!.path),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                      return Container(
                        height: 200,
                        color: Theme.of(context).colorScheme.surface,
                        child: Center(
                          child: Text(
                            'No image selected',
                            style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      );
                    },
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: ElevatedButton(
                        onPressed: addPhoto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                        ),
                        child: Text(
                          'CHOOSE PHOTO',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: ElevatedButton(
                  onPressed: addPost,
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    child: Text(
                      'ADD POST'
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
        Text(
          intensity.description,
          style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface),
        ),
        Radio<Intensity>(
          value: intensity,
          groupValue: selectedIntensity,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (Intensity? value) {
            setState(() {
              selectedIntensity = value;
            });
          },
        ),
      ],
    );
  }

  void addPost() async { //addPost je sada async jer čeka upload slike.
    if (workoutTypeController.text.isEmpty ||
        locationController.text.isEmpty ||
        _exercisesList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in Workout Type, Location, and at least one Exercise',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    String? photoURL = await uploadImageToFirebase(_image);

    final post = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        duration: selectedDate ?? DateTime.now(),
        location: locationController.text,
        photoURL: photoURL ?? '',
        playlist: playlistController.text,
        workout_type: workoutTypeController.text,
        intensity: selectedIntensity ?? Intensity.Easy,
        exercises: _exercisesList
    );

    context.read<PostBloc>().add(AddPost(addedPost: post));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Post added successfully!',
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  Future<String?> uploadImageToFirebase(XFile? image) async {
    if (image == null) return null;
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final reference = _storage.ref().child("images/$fileName");
      await reference.putFile(File(image.path));
      return await reference.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to upload image: $e',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return null;
    }
  }
}
