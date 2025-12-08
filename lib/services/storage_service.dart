import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/result.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload an image file to Firebase Storage
  /// Returns the download URL of the uploaded file
  Future<Result<String>> uploadImage({
    required File imageFile,
    required String path, // e.g., 'food_photos/{clientId}/{timestamp}.jpg'
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(imageFile);
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return Success(downloadUrl);
    } catch (e) {
      return Failure('Failed to upload image: $e');
    }
  }

  /// Upload food photo
  Future<Result<String>> uploadFoodPhoto({
    required File imageFile,
    required String clientId,
    required DateTime date,
  }) async {
    final timestamp = date.millisecondsSinceEpoch;
    final path = 'food_photos/$clientId/$timestamp.jpg';
    return uploadImage(imageFile: imageFile, path: path);
  }

  /// Delete an image from Firebase Storage
  Future<Result<void>> deleteImage(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete image: $e');
    }
  }
}

