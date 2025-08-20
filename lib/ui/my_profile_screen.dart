import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotter_app/bloc/post/post_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter_app/ui/profile_settings_screen.dart';
import 'package:spotter_app/ui/weekly_progress_screen.dart';
import 'package:spotter_app/ui/workout_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/auth/auth_bloc.dart';
import '../models/post.dart';
import '../models/user.dart' as app_user;
import '../repository/firebase_repo_implementation.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/auth');
      });
    } else {
      context.read<PostBloc>().add(const GetPosts());
    }
  }

  Future<void> _refreshPosts() async {
    context.read<PostBloc>().add(const GetPosts());
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Please sign in',
            style: GoogleFonts.poppins(fontSize: 18),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Workouts',
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
        child: RefreshIndicator(
          onRefresh: _refreshPosts,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<app_user.User?>(
                    future: context.read<FirebaseRepo>().getUser(userId),
                    builder: (context, snapshot) {
                      String username = 'Loading...';
                      String profilePictureUrl = 'assets/images/boy.png';
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                        username = snapshot.data!.username;
                        profilePictureUrl = snapshot.data!.profilePictureUrl.isNotEmpty
                            ? snapshot.data!.profilePictureUrl
                            : profilePictureUrl;
                      }
                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: profilePictureUrl.startsWith('assets/')
                                ? AssetImage(profilePictureUrl)
                                : CachedNetworkImageProvider(profilePictureUrl) as ImageProvider,
                            backgroundColor: Theme.of(context).colorScheme.surface,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            username,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Edit Profile',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const WeeklyProgressScreen()),
                              );
                            },
                            child: Text('View Weekly Progress', style: GoogleFonts.poppins()),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  if (state is FetchingPosts) {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is FetchedPosts) {
                    final userPosts = state.allPosts.where((post) => post.userId == userId).toList();
                    if (userPosts.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            'You have no published posts',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                      );
                    }
                    return postList(userPosts);
                  } else if (state is FetchingFailed) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Failed to load posts: ${state.error}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => context.read<PostBloc>().add(const GetPosts()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Try Again',
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(
                    child: Center(child: Text('No data available', style: TextStyle(fontSize: 16))),
                  );
                },
              ),
            ],
          ),
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
              title: Text('Settings', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Log Out', style: GoogleFonts.poppins()),
              onTap: () {
                context.read<AuthBloc>().add(SignOut());
                Navigator.pushReplacementNamed(context, '/auth');
              },
            ),
          ],
        ),
      ),

    );
  }

  Widget postList(List<Post> posts) {
    final firebaseRepo = context.read<FirebaseRepo>();
    final userCache = <String, app_user.User?>{};
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final post = posts[index];
          return FutureBuilder<app_user.User?>(
            future: userCache.containsKey(post.userId)
                ? Future.value(userCache[post.userId])
                : firebaseRepo.getUser(post.userId).then((user) {
              userCache[post.userId] = user;
              return user;
            }),
            builder: (context, snapshot) {
              String profilePictureUrl = 'assets/images/boy.png';
              String username = post.username;
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                profilePictureUrl = snapshot.data!.profilePictureUrl.isNotEmpty
                    ? snapshot.data!.profilePictureUrl
                    : profilePictureUrl;
                username = snapshot.data!.username;
              }
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<PostBloc>(),
                        child: WorkoutDetailScreen(workoutPost: post),
                      ),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 3,
                              child: Row(
                                children: [
                                  ClipOval(
                                    child: profilePictureUrl.startsWith('assets/')
                                        ? Image.asset(
                                      profilePictureUrl,
                                      width: MediaQuery.of(context).size.width * 0.15,
                                      height: MediaQuery.of(context).size.width * 0.15,
                                      fit: BoxFit.cover,
                                    )
                                        : CachedNetworkImage(
                                      imageUrl: profilePictureUrl,
                                      width: MediaQuery.of(context).size.width * 0.15,
                                      height: MediaQuery.of(context).size.width * 0.15,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) {
                                        return Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Theme.of(context).colorScheme.primary,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          username,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          post.location.isNotEmpty ? post.location : 'Unknown',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.alarm,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 1),
                                  Text(
                                    post.date != null
                                        ? '${post.date!.day}.${post.date!.month}.${post.date!.year} ${post.date!.hour.toString().padLeft(2, '0')}:${post.date!.minute.toString().padLeft(2, '0')}'
                                        : 'N/A',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          post.workout_type.isNotEmpty ? post.workout_type : 'Unknown',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 10),
                        if (post.photoURL != null && post.photoURL!.isNotEmpty && post.photoURL != '')
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: post.photoURL!,
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.width * 0.6,
                              fit: BoxFit.cover,
                              maxHeightDiskCache: 400,
                              memCacheHeight: 400,
                              placeholder: (context, url) => const SizedBox(
                                height: 200,
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) {
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: GestureDetector(
                                onTap: () async {
                                  final playlistUrl = post.playlist.isNotEmpty ? post.playlist : null;
                                  if (playlistUrl != null) {
                                    final uri = Uri.tryParse(playlistUrl);
                                    if (uri != null) {
                                      try {
                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Ne mogu otvoriti link')),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Nevažeći format URL-a')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Nema dostupnog linka za playlistu')),
                                    );
                                  }
                                },
                                child: Text(
                                  post.playlist.isNotEmpty ? post.playlist : 'No playlist',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: post.playlist.isNotEmpty
                                        ? Colors.blue
                                        : Theme.of(context).colorScheme.onSurface,
                                    decoration: post.playlist.isNotEmpty ? TextDecoration.underline : null,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
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
          );
        },
        childCount: posts.length,
      ),
    );
  }}