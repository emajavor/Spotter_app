import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:spotter_app/models/user.dart' as app_user;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotter_app/models/user.dart';
import 'package:spotter_app/repository/firebase_repo_implementation.dart';
import 'dart:io';

import '../models/user.dart' as app_user;

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  XFile? _profileImage;
  String? _currentProfilePictureUrl;
  Timestamp? _createdAt;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final user = await context.read<FirebaseRepo>().getUser(userId);
      if (user != null) {
        setState(() {
          _usernameController.text = user.username;
          _emailController.text = user.email;
          _currentProfilePictureUrl = user.profilePictureUrl;
          _createdAt = user.createdAt;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile;
      });
    }
  }

  Future<void> _saveProfile() async {
    final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Morate biti prijavljeni!', style: GoogleFonts.poppins()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Korisničko ime je obavezno!', style: GoogleFonts.poppins()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    String profilePictureUrl = _currentProfilePictureUrl ?? '';
    if (_profileImage != null) {
      profilePictureUrl = await context.read<FirebaseRepo>().uploadProfilePicture(_profileImage!, userId) ?? '';
    }

    final user = app_user.User(
      uid: userId,
      username: _usernameController.text.trim(),
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : 'Nema emaila',
      createdAt: _createdAt ?? Timestamp.now(),
      profilePictureUrl: profilePictureUrl,
    );

    await context.read<FirebaseRepo>().saveUser(user);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profil spremljen!', style: GoogleFonts.poppins()),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uredi profil', style: GoogleFonts.poppins()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(File(_profileImage!.path)) as ImageProvider
                    : (_currentProfilePictureUrl != null
                    ? NetworkImage(_currentProfilePictureUrl!) as ImageProvider
                    : null),
                child: _profileImage == null && (_currentProfilePictureUrl == null || _currentProfilePictureUrl!.isEmpty)
                    ? Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.primary)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Korisničko ime (obavezno)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
              ),
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.email, color: Theme.of(context).colorScheme.primary),
              ),
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Spremi',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}