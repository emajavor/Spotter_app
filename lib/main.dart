import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:spotter_app/bloc/post/post_bloc.dart';
import 'package:spotter_app/bloc/auth/auth_bloc.dart';
import 'package:spotter_app/repository/firebase_repo_implementation.dart';
import 'package:spotter_app/theme.dart';
import 'package:spotter_app/ui/home_screen.dart';
import 'package:spotter_app/ui/authorization/sign_in_screen.dart';
import 'package:spotter_app/ui/my_profile_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final firebaseRepo = FirebaseRepo();
  //migrateUsers is called before starting application so we ensure users collection has profile pic and username
  await firebaseRepo.migrateUsers();
  runApp(MyApp(firebaseRepo: firebaseRepo));
}

class MyApp extends StatelessWidget {
  final FirebaseRepo firebaseRepo;
  const MyApp({super.key, required this.firebaseRepo});//firebaseRepo se prosljeđuje u MyApp i koristi za kreiranje AuthBloc i PostBloc.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseRepo>.value(value: firebaseRepo),
        BlocProvider(create: (_) => AuthBloc(firebaseRepo)),
        BlocProvider(create: (_) => PostBloc(firebaseRepo)),
      ],
      child: MaterialApp(
        theme: SpotterTheme.darkTheme, //our flexcolorscheme theme applied
        initialRoute: '/auth',
        routes: {
          '/auth': (context) => const SignInScreen(),
          '/start': (context) => const HomeScreen(),
          '/profile': (context) => const MyProfileScreen(),
        },
      ),
    );
  }
}
