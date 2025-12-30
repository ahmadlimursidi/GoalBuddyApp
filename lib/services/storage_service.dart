import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a drill animation file to Firebase Storage
  Future<String?> uploadDrillAnimation(File file, String path) async {
    try {
      // Upload the file to the specified path
      await _storage.ref(path).putFile(file);
      
      // Get the download URL
      String downloadUrl = await _storage.ref(path).getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print("Error uploading animation: $e");
      return null;
    }
  }

  /// Deletes a drill animation file from Firebase Storage
  Future<void> deleteDrillAnimation(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      print("Error deleting animation: $e");
    }
  }

  /// Gets the download URL for a drill animation
  Future<String?> getAnimationUrl(String path) async {
    try {
      String downloadUrl = await _storage.ref(path).getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error getting animation URL: $e");
      return null;
    }
  }
}