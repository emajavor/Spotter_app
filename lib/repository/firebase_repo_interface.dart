
import 'package:image_picker/image_picker.dart';
import 'package:spotter_app/models/post.dart';

import '../models/user.dart';

abstract class IFirebaseRepo {
  Future<List<Post>> getAll();

  Future<void> updateField(String documentId, String newIntensity);
  Future<Post?> getPost(String id);
  Future<void> addPost(Post addedPost);
  Future<String?> uploadImage(XFile image);
  Future<void> saveUser(User user);
  Future<User?> getUser(String uid);
  Future<String?> uploadProfilePicture(XFile image, String uid);
  Future<void> migrateUsers();
}