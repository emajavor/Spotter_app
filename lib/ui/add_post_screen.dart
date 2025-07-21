import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
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

import '../repository/firebase_repo_implementation.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final exerciseController = TextEditingController();
  final workoutTypeController = TextEditingController();
  final locationController = TextEditingController();
  final playlistController = TextEditingController();
  Intensity? selectedIntensity = Intensity.Easy;
  DateTime? selectedDate;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    exerciseController.dispose();
    workoutTypeController.dispose();
    locationController.dispose();
    playlistController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void addPhoto() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Choose Image',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 'camera');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(80, 80),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 30,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 'gallery');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(80, 80),
              ),
              child: const Icon(
                Icons.image_search_rounded,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );

    PermissionStatus permissionStatus;
    ImageSource source;
    if (result == 'camera') {
      permissionStatus = await Permission.camera.request();
      source = ImageSource.camera;
    } else if (result == 'gallery') {
      permissionStatus = await Permission.photos.request();
      source = ImageSource.gallery;
    } else {
      return;
    }

    if (permissionStatus.isGranted) {
      final pickedFile = await _picker.pickImage(source: source);
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
            result == 'camera'
                ? 'Camera permission denied'
                : 'Photo permission denied',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> addDateTime() async {
    final pickedDate = await showOmniDateTimePicker(context: context);
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      listener: (context, state) async {
        if (state is AddedPost) {
          print("Emitting AddedPost state: ${state.addedPost}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Post successfully added!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 2),
            ),
          );
          setState(() => _isLoading = false);
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            context.read<PostBloc>().add(const GetPosts());
            // Navigate to HomeScreen with Profile tab
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/start',
                  (route) => false,
              arguments: {'initialIndex': 2}, // Select Profile tab
            );
          }
        } else if (state is FailedAddedPost) {
          print("Emitting FailedAddedPost state: ${state.error}");
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error when posting: ${state.error}',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Post'),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
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
                      buildWhen: (prev, curr) =>
                          curr is AddedExercises ||
                          curr is EmptyExercises ||
                          curr is AddingExercise,
                      builder: (context, state) {
                        print("state in AddedScreen is $state");
                        if (state is AddedExercises) {
                          print(state);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: state.addedExercises
                                .map((exercise) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                      child: Text(
                                        exercise,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          );
                        }
                        return Container();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
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
                        style: GoogleFonts.poppins(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (exerciseController.text.isNotEmpty) {
                              context.read<PostBloc>().add(AddExercises(
                                  addedExercises: exerciseController.text));
                              exerciseController.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'ADD EXERCISE',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 15),
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
                      buildWhen: (prev, curr) =>
                          curr is AddedWorkoutType ||
                          curr is AddingWorkoutType ||
                          curr is EmptyWorkoutType,
                      builder: (context, state) {
                        String? workoutType;
                        if (state is AddedWorkoutType) {
                          workoutType = state.addedWorkoutType;
                        } // Spremi vrijednost iz Bloca
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (workoutType != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 15.0),
                                child: Text(
                                  workoutType,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 16),
                              child: TextField(
                                controller: workoutTypeController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  hintText: 'Enter workout type',
                                  prefixIcon: Icon(Icons.fitness_center,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                style: GoogleFonts.poppins(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (workoutTypeController.text.isNotEmpty) {
                                      context.read<PostBloc>().add(
                                          AddWorkoutType(
                                              addedWorkoutType:
                                                  workoutTypeController.text));
                                      workoutTypeController.clear();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: Text(
                                    workoutType == null ? 'SAVE' : 'EDIT',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                color: Theme.of(context).colorScheme.surface,
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 10),
                      child: Text(
                        'Date & Time:',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Text(
                        selectedDate != null
                            ? '${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year} ${selectedDate!.hour}:${selectedDate!.minute}'
                            : 'Not selected',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: ElevatedButton(
                          onPressed: addDateTime,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            selectedDate == null ? 'SELECT' : 'EDIT',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600),
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
                            curr is AddedLocation ||
                            curr is AddingLocation ||
                            curr is EmptyLocation,
                        builder: (context, state) {
                          String? location;
                          if (state is AddedLocation) {
                            location = state
                                .addedLocation; // Spremi vrijednost iz Bloca
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (location != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 15.0),
                                  child: Text(
                                    location,
                                    style: GoogleFonts.poppins(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 16),
                                child: TextField(
                                  controller: locationController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    hintText: 'Enter your location',
                                    prefixIcon: Icon(
                                      Icons.location_on,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  style: GoogleFonts.poppins(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (locationController.text.isNotEmpty) {
                                        context.read<PostBloc>().add(
                                            AddLocation(
                                                addedLocation:
                                                    locationController.text));
                                        locationController.clear();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      location == null ? 'SAVE' : 'EDIT',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
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
                          curr is AddedPlaylist ||
                          curr is AddingPlaylist ||
                          curr is EmptyPlaylist,
                      builder: (context, state) {
                        String? playlist;
                        if (state is AddedPlaylist) {
                          playlist = state.addedPlaylist;
                        } // Spremi vrijednost iz Bloca
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (playlist != null)
                              InkWell(
                                onTap: () async {
                                  final url = Uri.parse(playlist!);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 15.0),
                                  child: Text(
                                    playlist,
                                    style: GoogleFonts.poppins(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 16),
                              child: TextField(
                                controller: playlistController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  hintText: 'Paste your playlist link',
                                  prefixIcon: Icon(Icons.music_note,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                style: GoogleFonts.poppins(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (playlistController.text.isNotEmpty) {
                                      context.read<PostBloc>().add(AddPlaylist(
                                          addedPlaylist:
                                              playlistController.text));
                                      playlistController.clear();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: Text(
                                    playlist == null ? 'SAVE' : 'EDIT',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
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
                          _buildIntensityItem(Intensity.Easy),
                          _buildIntensityItem(Intensity.Intermediate),
                          _buildIntensityItem(Intensity.Hard),
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
                          curr is AddedImage ||
                          curr is EmptyImage ||
                          curr is AddingImage,
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
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color:
                                            Theme.of(context).colorScheme.error,
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
                              style: GoogleFonts.poppins(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
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
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 15.0),
                          ),
                          child: Text(
                            'CHOOSE PHOTO',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                      setState(() => _isLoading = true);
                      final postBloc = context.read<PostBloc>();
                      final userId = firebase_auth
                          .FirebaseAuth.instance.currentUser?.uid;
                      if (userId == null) {
                        setState(() => _isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'You have to be signed in!',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor:
                            Theme.of(context).colorScheme.error,
                          ),
                        );
                        return;
                      }
                      final user = await context
                          .read<FirebaseRepo>()
                          .getUser(userId);
                      final username = user?.username ?? 'User';
                      if (postBloc.workoutType.isEmpty) {
                        setState(() => _isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Add workout type!',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor:
                            Theme.of(context).colorScheme.error,
                          ),
                        );
                        return;
                      }
                      if (postBloc.location.isEmpty) {
                        setState(() => _isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Add your location!',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor:
                            Theme.of(context).colorScheme.error,
                          ),
                        );
                        return;
                      }
                      if (postBloc.exercises.isEmpty) {
                        setState(() => _isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Add at least one exercise!',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor:
                            Theme.of(context).colorScheme.error,
                          ),
                        );
                        return;
                      }
                      String photoURL = '';
                      if (_image != null) {
                        try {
                          photoURL = await context.read<FirebaseRepo>().uploadImage(_image!) ?? '';
                        } catch (e) {
                          print('Failed to upload image: $e');
                        }
                      }
                      try {
                        final post = Post(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          duration: selectedDate ?? DateTime.now(),
                          location: postBloc.location,
                          photoURL: photoURL,
                          playlist: playlistController.text,
                          workout_type: postBloc.workoutType,
                          intensity: selectedIntensity ?? Intensity.Easy,
                          exercises: postBloc.exercises,
                          userId: userId,
                          username: username,
                          likes: [],
                          comments: [],
                        );
                        context.read<PostBloc>().add(AddPost(addedPost: post));
                        await Future.delayed(const Duration(milliseconds: 500));
                        setState(() => _isLoading = false);
                      } catch (e) {
                        setState(() => _isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error creating post: $e',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor:
                            Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    child: Text(
                      'ADD POST',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface),
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
}
