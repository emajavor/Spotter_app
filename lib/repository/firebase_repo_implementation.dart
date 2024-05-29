import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:spotter_app/repository/firebase_repo_interface.dart';

import '../db/virtual_db.dart';
import '../models/post.dart';
import 'package:http/http.dart' as http;



class FirebaseRepo implements IFirebaseRepo {
  final db = FirebaseFirestore.instance;

  FirebaseRepo();

  @override
  Future<List<Post>> getAll() async {

    List<Post> postList = [];
    CollectionReference collectionRef = db.collection("posts");
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectionRef.get();
    // Get data from docs and convert map to List
    final posts = querySnapshot.docs.map((doc) => doc.data()).toList();
    posts.forEach((element) {
      try {
        print(element);
        Post post = Post.fromJson(element as Map<String, dynamic>);
        postList.add(post);
      } catch (e) {
        print("error: ${e.toString()}");
      }

    });
    debugPrint("Posts list ${postList.toString()}");
    //
     return postList;
  }

  // db.collection("cities").get().then(
  // (querySnapshot) {
  // print("Successfully completed");
  // for (var docSnapshot in querySnapshot.docs) {
  // print('${docSnapshot.id} => ${docSnapshot.data()}');
  // }
  // },
  // onError: (e) => print("Error completing: $e"),
  // );
  Future<Post> fetchAlbum() async {
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load post');
    }
  }
}