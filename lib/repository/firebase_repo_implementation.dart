
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:spotter_app/repository/firebase_repo_interface.dart';

import '../models/post.dart';



class FirebaseRepo implements IFirebaseRepo {
  final db = FirebaseFirestore.instance;

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
  Future<void> addPost(Post addedPost) async {
    final post = addedPost;

    db.collection("posts").add(post.toMap()).then((documentSnapshot) =>
        print("Added Data with ID: ${documentSnapshot.id}"));
  }
}