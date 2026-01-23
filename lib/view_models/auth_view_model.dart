import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart'; // Import Firestore
import '../services/notification_service.dart'; // Import Notification Service

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService(); // Instance
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getter to access current user
  User? get currentUser => _authService.currentUser;

  // Get current user's name from Firestore
  Future<String> getCurrentUserName() async {
    final user = currentUser;
    if (user == null) return 'Coach';

    try {
      final doc = await _firestoreService.getCoachById(user.uid);
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['name'] ?? 'Coach';
      }
      return 'Coach';
    } catch (e) {
      print("Error getting user name: $e");
      return 'Coach';
    }
  }

  // Login Logic - NOW RETURNS THE ROLE (String?)
  Future<String?> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      if (email.isEmpty || password.isEmpty) {
        throw "Please fill in all fields.";
      }

      // 1. Authenticate with Firebase Auth
      final user = await _authService.signIn(email, password);
      
      if (user == null) throw "Login failed.";

      // DEBUG: Print UID
      print("DEBUG: Login successful. User UID: ${user.uid}");

      // 2. Fetch User Role from Firestore
      String role = await _firestoreService.getUserRole(user.uid);

      // DEBUG: Print Role
      print("DEBUG: Role fetched from Firestore: $role");

      // 3. Initialize FCM and store token
      await _notificationService.initializeAndStoreToken(user.uid);
      print("DEBUG: FCM token initialized for user");

      _setLoading(false);
      return role; // Return 'admin' or 'coach'
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      print("DEBUG: Login Error: $e");
      return null; // Return null on failure
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> logout() async {
    // Remove FCM token before signing out
    final user = currentUser;
    if (user != null) {
      await _notificationService.removeToken(user.uid);
    }
    await _authService.signOut();
    notifyListeners();
  }

  /// Check if user is already logged in and get their role
  /// Returns the role string if logged in, null if not
  Future<String?> checkExistingSession() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      // User is logged in, fetch their role
      String role = await _firestoreService.getUserRole(user.uid);

      // Re-initialize FCM token (in case it changed)
      await _notificationService.initializeAndStoreToken(user.uid);

      return role;
    } catch (e) {
      print("DEBUG: Error checking existing session: $e");
      return null;
    }
  }
}