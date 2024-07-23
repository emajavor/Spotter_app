
import 'package:spotter_app/models/post.dart';

abstract class IFirebaseRepo {
  Future<List<Post>> getAll();

  Future<void> updateField(String documentId, String newIntensity);
}