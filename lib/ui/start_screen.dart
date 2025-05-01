import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotter_app/bloc/post/post_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter_app/ui/add_post_screen.dart';
import 'package:spotter_app/ui/workout_detail_screen.dart';

import '../bloc/auth/auth_bloc.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    BlocProvider.of<PostBloc>(context).add(const GetPosts());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                  value: BlocProvider.of<PostBloc>(context),
                  child: const AddPostScreen()),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text(
          'Your Workouts',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOut());
              Navigator.pushReplacementNamed(context, '/auth');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<PostBloc, PostState>(
          buildWhen: (prev, curr) =>
              curr is FetchedPosts || curr is FetchingPosts,
          builder: (context, state) {
            print("State in StartScreen is: $state");
            if (state is FetchedPosts) {
              return postList(state);
            } else if (state is FetchingPosts) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Container(child: Text('No posts available'));
            }
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Profile',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Item 1',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                // Dodaj funkcionalnost za Item 1
              },
            ),
            ListTile(
              title: Text(
                'Item 2',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                // Dodaj funkcionalnost za Item 2
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget postList(state) {
    try {
      return ListView.separated(
        itemBuilder: (context, index) {
          final post = state.allPosts[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                      value: context.read<PostBloc>(),
                      child: WorkoutDetailScreen(
                        workoutPost: post,
                      )),
                ),
              );
            },
            child: Card(
              color: Theme.of(context).colorScheme.surface,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: Image.network(
                            'https://avatar.iran.liara.run/public/boy?username=Ash',
                            width: MediaQuery.of(context).size.width * 0.15,
                            height: MediaQuery.of(context).size.width * 0.15,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.error,
                                size: 50,
                                color: Theme.of(context).colorScheme.error,
                              );
                            }, // shows icon if image cant be shown
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                post.location ?? 'Unknown',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.alarm,
                                    size: MediaQuery.of(context).size.width *
                                        0.06,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      post.duration?.toString() ?? 'N/A',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      post.workout_type ?? 'Unknown',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 10),
                    if (post.photoURL != null && post.photoURL!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post.photoURL!,
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.width * 0.6,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(context).colorScheme.surface,
                              height: MediaQuery.of(context).size.width * 0.6,
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.music_note_rounded,
                          size: MediaQuery.of(context).size.width * 0.05,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            post.playlist ?? 'No playlist',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(),
        itemCount: state.allPosts.length,
      );
    } catch (e) {
      print(e);
      return Container();
    }
  }
}
