import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';

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

  /// Uploads a PDF file (from bytes) to Firebase Storage
  /// Returns the download URL if successful
  Future<String?> uploadPdfFromBytes({
    required Uint8List pdfBytes,
    required String fileName,
    required String folder,
  }) async {
    try {
      // Create a unique file path: pdfs/session_templates/filename_timestamp.pdf
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String path = '$folder/${fileName}_$timestamp.pdf';

      // Upload the PDF bytes to Firebase Storage
      final UploadTask uploadTask = _storage.ref(path).putData(
        pdfBytes,
        SettableMetadata(contentType: 'application/pdf'),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print("✅ PDF uploaded successfully to: $path");
      return downloadUrl;
    } catch (e) {
      print("❌ Error uploading PDF: $e");
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

  /// Deletes a PDF file from Firebase Storage given its download URL
  Future<void> deletePdfByUrl(String downloadUrl) async {
    try {
      // Extract the path from the download URL
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      print("✅ PDF deleted successfully");
    } catch (e) {
      print("❌ Error deleting PDF: $e");
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