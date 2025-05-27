
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotter_app/repository/firebase_repo_interface.dart';

import '../models/post.dart';
import '../models/user.dart';



class FirebaseRepo implements IFirebaseRepo {
  final db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseRepo();

  @override
  Future<List<Post>> getAll() async {

    List<Post> postList = [];
    CollectionReference collectionRef = db.collection("posts");
    QuerySnapshot querySnapshot = await collectionRef.get();
    final posts = querySnapshot.docs.map((doc) => doc.data()).toList();

    for (var element in posts) {
      try {
        print(element);
        Post post = Post.fromJson(element as Map<String, dynamic>);
        postList.add(post);
      } catch (e) {
        print("error: ${e.toString()}");
      }

    }
    debugPrint("Posts list ${postList.toString()}");
    return postList;
  }

  // Future<Post> fetchPost() async {
  //   final response = await http
  //       .get(Uri.parse(''));
  //
  //   if (response.statusCode == 200) {
  //     // If the server did return a 200 OK response,
  //     // then parse the JSON.
  //     return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  //   } else {
  //     // If the server did not return a 200 OK response,
  //     // then throw an exception.
  //     throw Exception('Failed to load post');
  //   }
  // }

  @override
  Future<void> updateField(String documentId, String newIntensity) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(documentId)
          .update({'intensity': newIntensity});
      print('Document successfully updated!');
    } catch (e) {
      print('Error updating document: $e');
    }
  }
  @override
  Future<Post?> getPost(String id) async {
    Post? post;
    final docRef = db.collection("posts").doc(id);
    await docRef.get().then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        post = Post.fromJson(data);
      },
      onError: (e) => print("Error getting document: $e"),
    );

    return post;
  }

  @override
  Future<void> addPost(Post post) async {
    try {
      if (post.userId.isEmpty) {
        throw Exception('userId cannot be empty');
      }
      if (post.username.isEmpty) {
        final user = await getUser(post.userId);
        if (user == null) {
          throw Exception('User not found for userId: ${post.userId}');
        }
        post = post.copyWith(username: user.username);
      }
      // Set default photoURL if null
      post = post.copyWith(photoURL: post.photoURL.isEmpty ? '' : post.photoURL);
      print("Adding post: ${post.toString()}");
      await db.collection('posts').doc(post.id).set(post.toJson());
      print("Post added successfully: ${post.id}");
    } catch (e) {
      print("Error adding post: $e");
      rethrow;
    }
  }

  @override
  Future<String?> uploadImage(XFile image) async {
    try {
      File fileToUpload = File(image.path);
      // Try to compress image
      try {
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          image.path,
          '${image.path}_compressed.jpg',
          quality: 85,
          minWidth: 800,
          minHeight: 600,
        );
        if (compressedFile != null) {
          fileToUpload = File(compressedFile.path);
          print("Image compressed successfully");
        } else {
          print("Compression failed, using original image");
        }
      } catch (e) {
        print("Compression error: $e, using original image");
      }

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final reference = _storage.ref().child("post_images/$fileName");
      await reference.putFile(fileToUpload);
      final url = await reference.getDownloadURL();
      print("Image uploaded: $url");
      return url;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> saveUser(User user) async {
    try {
      await db.collection("users").doc(user.uid).set(user.toJson());
      print("User saved: ${user.uid}, ${user.username}");
    } catch (e) {
      print("Error saving user: $e");
      rethrow;
    }
  }

  Future<User?> getUser(String uid) async {
    try {
      final doc = await db.collection("users").doc(uid).get();
      if (doc.exists) {
        return User.fromJson(doc.data() as Map<String, dynamic>);
      }
      print("User not found: $uid");
      return null;
    } catch (e) {
      print("Error getting user: $e");
      return null;
    }
  }

  Future<String?> uploadProfilePicture(XFile image, String uid) async {
    try {
      final fileName = "profile_$uid";
      final reference = _storage.ref().child("profile_pictures/$fileName");
      await reference.putFile(File(image.path));
      final url = await reference.getDownloadURL();
      print("Profile picture uploaded: $url");
      return url;
    } catch (e) {
      print("Error uploading profile picture: $e");
      return null;
    }
  }

  Future<void> migrateUsers() async {
    try {
      final users = await db.collection("users").get();
      for (var doc in users.docs) {
        final data = doc.data();
        await doc.reference.update({
          'username': data['username'] ?? 'Korisnik',
          'profilePictureUrl': data['profilePictureUrl'] ?? '',
        });
        print("Updated user: ${doc.id}");
      }
    } catch (e) {
      print("Error migrating users: $e");
    }
  }
}