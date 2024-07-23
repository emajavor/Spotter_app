import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter_app/bloc/post/post_bloc.dart';
import 'package:spotter_app/repository/firebase_repo_implementation.dart';
import 'package:spotter_app/ui/start_screen.dart';
import 'firebase_options.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());

}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: BlocProvider(
          create: (BuildContext context) => PostBloc(),
          child: const StartScreen()),
    );
  }
}

