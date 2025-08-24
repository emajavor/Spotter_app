import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotter_app/bloc/post/post_bloc.dart';
import 'package:spotter_app/repository/firebase_repo_implementation.dart';
import 'package:spotter_app/ui/workout_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart' as app_user;

import '../models/post.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {

  final Map<String, app_user.User> _userCache = {};

  Future<app_user.User?> _getUser(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }
    final user = await context.read<FirebaseRepo>().getUser(userId);
    if (user != null) {
      _userCache[userId] = user;
    }
    return user;
  }

  final Map<String, Future<app_user.User?>> _userFutureCache = {};

  Future<app_user.User?> _getUserCached(String userId) {
    if (!_userFutureCache.containsKey(userId)) {
      _userFutureCache[userId] = _getUser(userId);
    }
    return _userFutureCache[userId]!;
  }

  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(GetPosts(userId: firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? ''));  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feed',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: BlocConsumer<PostBloc, PostState>(
        listener: (context, state) {
          if (state is FetchingFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error while loading: ${state.error}',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FetchingPosts) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FetchedPosts) {
            if (state.allPosts.isEmpty) {
              return Center(
                child: Text(
                  'No posts yet!',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PostBloc>().add(GetPosts(userId: firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? ''));
                },
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final post = state.allPosts[index];
                  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                  final isLiked = currentUserId != null && post.likes.contains(currentUserId);
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
                                  child: FutureBuilder<app_user.User?>(
                                    future: _getUserCached(post.userId),
                                    builder: (context, snapshot) {
                                      String profilePictureUrl = 'assets/images/boy.png';
                                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                                        profilePictureUrl = snapshot.data!.profilePictureUrl.isNotEmpty
                                            ? snapshot.data!.profilePictureUrl
                                            : profilePictureUrl;
                                      }
                                      return profilePictureUrl.startsWith('assets/')
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
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Username
                                          Flexible(
                                            child: Text(
                                              post.username,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          // Location
                                          Flexible(
                                            child: Text(
                                              post.location,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      // Alarm icon and date
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.alarm,
                                            size: MediaQuery.of(context).size.width * 0.06,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              post.date != null
                                                  ? '${post.date!.day}.${post.date!.month}.${post.date!.year} ${post.date!.hour.toString().padLeft(2, '0')}:${post.date!.minute.toString().padLeft(2, '0')}'
                                                  : 'N/A',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                color: Theme.of(context).colorScheme.onSurface,
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
                              post.workout_type.isNotEmpty ? post.workout_type : 'Unknown',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 10),
                            if (post.photoURL.isNotEmpty && post.photoURL != '')
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  post.photoURL,
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
                                  child: GestureDetector(
                                    onTap: () async {
                                      final playlistUrl = post.playlist ?? '';
                                      if (playlistUrl.isNotEmpty) {
                                        final cleanUrl = playlistUrl.split('?').first;
                                        final uri = Uri.tryParse(cleanUrl);
                                        if (uri == null || !uri.hasAbsolutePath) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Invalid URL format')),
                                          );
                                          return;
                                        }

                                        try {
                                          bool launched = await launchUrl(
                                            uri,
                                            mode: LaunchMode.externalApplication,
                                          );

                                          if (!launched) {
                                            launched = await launchUrl(
                                              uri,
                                              mode: LaunchMode.platformDefault,
                                            );
                                          }

                                          if (!launched) {
                                            launched = await launchUrl(
                                              uri,
                                              mode: LaunchMode.inAppBrowserView,
                                            );
                                          }

                                          if (!launched) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Unable to open link')),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error opening link: $e')),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('No playlist link available')),
                                        );
                                      }
                                    },
                                    child: Text(
                                      post.playlist ?? 'No playlist',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: post.playlist != null && post.playlist!.isNotEmpty
                                            ? Colors.blue
                                            : Theme.of(context).colorScheme.onSurface,
                                        decoration: post.playlist != null && post.playlist!.isNotEmpty
                                            ? TextDecoration.underline
                                            : null,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: isLiked
                                            ? Theme.of(context).colorScheme.error
                                            : Theme.of(context).colorScheme.primary,
                                      ),
                                      onPressed: () {
                                        if (currentUserId != null) {
                                          context.read<PostBloc>().add(ToggleLikePost(post.id, currentUserId));
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Please sign in to like posts!',
                                                style: GoogleFonts.poppins(),
                                              ),
                                              backgroundColor: Theme.of(context).colorScheme.error,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    Text(
                                      '${post.likes.length}',
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.comment,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    _showCommentDialog(context, post);
                                  },
                                ),
                              ],
                            ),
                            // Display Comments (limited to 2 for brevity)
                            if (post.comments.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: post.comments.take(2).map((comment) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Text(
                                        '${comment.username}: ${comment.text}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemCount: state.allPosts.length,
              ),
            );
          }
    else if (state is AddingPost || state is AddedPost) {
    return const Center(child: CircularProgressIndicator());
        }
          return Center(
            child: Text(
              'Something went wrong. Try refreshing.',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
    },
      ),
    );
  }
  void _showCommentDialog(BuildContext context, Post post) {
    final TextEditingController _commentController = TextEditingController();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Comment', style: GoogleFonts.poppins()),
        content: TextField(
          controller: _commentController,
          decoration: InputDecoration(
            labelText: 'Your comment',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () async {
              if (_commentController.text.isNotEmpty && currentUserId != null) {
                // Fetching username from firestore
                final userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUserId)
                    .get();
                final currentUsername = userDoc.data()?['username'] as String? ?? 'Anonymous';

                final newComment = Comment(
                  userId: currentUserId,
                  username: currentUsername,
                  text: _commentController.text,
                  timestamp: Timestamp.now(),
                );
                context.read<PostBloc>().add(AddComment(post.id, newComment));
                Navigator.pop(context);
              }
            },
            child: Text('Submit', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}