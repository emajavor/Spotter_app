import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String username;
  final String email;
  final Timestamp createdAt;
  final String profilePictureUrl;

  User({
    required this.uid,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print("Parsing user: $json");
    return User(
      uid: json['uid'] as String? ?? '',
      username: json['username'] as String? ?? 'Korisnik',
      email: json['email'] as String? ?? '',
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      profilePictureUrl: json['profilePictureUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'createdAt': createdAt,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}