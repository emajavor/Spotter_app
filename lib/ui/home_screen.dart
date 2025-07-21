import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotter_app/ui/add_post_screen.dart';
import 'package:spotter_app/ui/my_profile_screen.dart';

import 'feed_screen.dart';

// Main screen with BottomNavigationBar
class HomeScreen extends StatefulWidget { //stateful jer cemo mijenjanjem indexa upravljati navigacijom
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Lista ekrana za navigaciju
  final List<Widget> _screens = [
    const FeedScreen(),
    const AddPostScreen(),
    const MyProfileScreen(),
    //const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Check for initialIndex from route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('initialIndex')) {
        setState(() {
          _currentIndex = args['initialIndex'] as int;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Prikazuje trenutni ekran
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index){
          setState(() {
            _currentIndex = index; //ontap se mijenja current index
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.feed_outlined, size: 28,),
          label: 'Feed',
            tooltip: 'Scroll through all posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 28),
            label: 'Add Post',
            tooltip: 'Add a new post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined, size: 28,),
          label: 'Profile',
            tooltip: 'Check out your own posts',
          ),
        ],
      ),
    );
  }
}