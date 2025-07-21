import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotter_app/bloc/post/post_bloc.dart';
import 'package:spotter_app/ui/workout_detail_screen.dart';

import '../models/post.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(const GetPosts());
  }

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
          print('Listener state: $state');
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
          print('Current state: $state');
          if (state is FetchingPosts) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FetchedPosts) {
            print('Posts fetched: ${state.allPosts.length}');
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
                context.read<PostBloc>().add(const GetPosts());
              },
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final post = state.allPosts[index];
                  print('Rendering post ${post.id}');
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
                                  child: Image.network(
                                    post.username.isNotEmpty
                                        ? 'https://avatar.iran.liara.run/public/boy?username=${post.username}'
                                        : 'https://avatar.iran.liara.run/public/boy?username=Unknown',
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    height: MediaQuery.of(context).size.width * 0.15,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.error,
                                        size: 50,
                                        color: Theme.of(context).colorScheme.error,
                                      );
                                    },
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
                                          color: Theme.of(context).colorScheme.onSurface,
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
                                            size: MediaQuery.of(context).size.width * 0.06,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              post.duration != null
                                                  ? '${post.duration?.day}.${post.duration?.month}.${post.duration?.year} ${post.duration?.hour}:${post.duration?.minute}'
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
                            if (post.photoURL != null && post.photoURL!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  post.photoURL!,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: MediaQuery.of(context).size.width * 0.6,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Image error for ${post.username}: $error');
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
    final currentUsername = FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous';

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
            onPressed: () {
              if (_commentController.text.isNotEmpty && currentUserId != null) {
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