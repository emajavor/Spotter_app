import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter_app/ui/widgets/intensity_card.dart';

import '../bloc/post/post_bloc.dart';
import '../models/enums/intensity.dart';

class AddPostScreen extends StatefulWidget{
  AddPostScreen();
  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
  Intensity? selectedIntensity;

}

class _AddPostScreenState extends State<AddPostScreen>{
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    myController.dispose();
    super.dispose();
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
              content: Text(
                  'Post is added')));
        }
        else {
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
          Intensity? selectedIntensity = Intensity.Easy;
          final myController = TextEditingController();

          return Column(
            children: <Widget>[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [
                    Padding(
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: TextField(
                        controller: myController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter an exercise',
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(padding: EdgeInsets.only(
                          bottom: 15.0),
                      child: ElevatedButton(
                          onPressed: () => showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text('Add exercise'),
                              actions: <TextField>[
                                TextField(
                                  controller: myController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter an exercise',
                                  ),
                                ),
                              ],
                            ),
                          ), child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 15.0),
                        child: Text(
                          'ADD EXERCISE',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),),),
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: TextField(
                        controller: myController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter a workout type',
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
                        controller: myController,
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
                                selectedIntensity = value;
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
                              selectedIntensity = value;
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
                              selectedIntensity = value;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
        ),
      ),
    );
  }
}




