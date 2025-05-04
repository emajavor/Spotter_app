import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotter_app/ui/add_post_screen.dart';
import 'package:spotter_app/ui/feed_screen.dart';
import 'package:spotter_app/ui/workout_detail_screen.dart';

// Placeholder ekran za Feed (za buduću implementaciju prikaza postova)
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Feed - Coming Soon',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// Glavni ekran s BottomNavigationBar
class HomeScreen extends StatefulWidget { //stateful jer cemo mijenjanjem indexa upravljati navigacijom
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Praćenje trenutno odabranog ekrana

  // Lista ekrana za navigaciju
  final List<Widget> _screens = [
    const FeedScreen(),
    const AddPostScreen(),
    //const ProfileScreen()
    // Dodaj buduće ekrane ovdje (npr. ProfileScreen, SettingsScreen)
  ];

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
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 28),
            label: 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined, size: 28,),
          label: 'Profile',
          ),
        ],
      ),
    );
  }
}