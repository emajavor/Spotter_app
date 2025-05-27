import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotter_app/bloc/post/post_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter_app/ui/profile_settings_screen.dart';
import 'package:spotter_app/ui/workout_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../bloc/auth/auth_bloc.dart';
import '../models/post.dart';
import '../models/user.dart' as app_user;
import '../repository/firebase_repo_implementation.dart';
import 'add_post_screen.dart';

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
    print("Current user ID: $userId");
    if (userId == null) {
      print("No user logged in, redirecting to auth");
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
                      String profilePictureUrl = 'https://via.placeholder.com/150';
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
                            backgroundImage: CachedNetworkImageProvider(profilePictureUrl),
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
                        ],
                      );
                    },
                  ),
                ),
              ),
              BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  print("State in MyProfileScreen: $state");
                  if (state is FetchingPosts) {
                    return const SliverToBoxAdapter(
                      child: Center(
                          child: CircularProgressIndicator()),
                    );
                  } else if (state is FetchedPosts) {
                    print("All posts: ${state.allPosts}");
                    final userPosts = state.allPosts.where((post) {
                      print("Checking post userId: ${post.userId} vs $userId");
                      return post.userId == userId;
                    }).toList();
                    print("Filtered user posts: $userPosts");
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
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'No posts available',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ),
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     print("Navigating to AddPostScreen");
      //     Navigator.of(context).push(
      //       MaterialPageRoute(builder: (context) => const AddPostScreen()),
      //     );
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  Widget postList(List<Post> posts) {
    final firebaseRepo = context.read<FirebaseRepo>();
    // Cache user data to avoid multiple Firestore calls
    final userCache = <String, app_user.User?>{};

    try {
      print("Rendering post list with ${posts.length} posts for user: ${firebase_auth.FirebaseAuth.instance.currentUser?.uid}");
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
                String profilePictureUrl = 'https://via.placeholder.com/150';
                String username = post.username; // Fallback to post.username
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
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: profilePictureUrl,
                                  width: MediaQuery.of(context).size.width * 0.15,
                                  height: MediaQuery.of(context).size.width * 0.15,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.alarm,
                                        size: MediaQuery.of(context).size.width * 0.06,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        post.duration != null
                                            ? '${post.duration?.day}.${post.duration?.month}.${post.duration?.year} ${post.duration?.hour}:${post.duration?.minute}'
                                            : 'N/A',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ],
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
                          if (post.photoURL.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: post.photoURL,
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: MediaQuery.of(context).size.width * 0.6,
                                fit: BoxFit.cover,
                                maxHeightDiskCache: 400,
                                memCacheHeight: 400,
                                placeholder: (context, url) => const SizedBox(
                                  height: 200,
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Theme.of(context).colorScheme.surface,
                                  height: MediaQuery.of(context).size.width * 0.6,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
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
                                  post.playlist.isNotEmpty ? post.playlist : 'No playlist',
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
            );
          },
          childCount: posts.length,
        ),
      );
    } catch (e) {
      print("Error in postList: $e");
      return SliverToBoxAdapter(
        child: Center(
          child: Text(
            'Failed to display posts',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
      );
    }
  }
}