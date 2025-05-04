import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter_app/bloc/post/post_bloc.dart';
import 'package:spotter_app/bloc/auth/auth_bloc.dart';
import 'package:spotter_app/theme.dart';
import 'package:spotter_app/ui/home_screen.dart';
import 'package:spotter_app/ui/feed_screen.dart';
import 'package:spotter_app/ui/auth_screen.dart';
import 'firebase_options.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => PostBloc()),
      ],
      child: MaterialApp(
        theme: SpotterTheme.darkTheme, //our flexcolorscheme theme applied
        initialRoute: '/auth',
        routes: {
          '/auth': (context) => const AuthScreen(),
          '/start': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
