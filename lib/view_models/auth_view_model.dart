import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart'; // Import Firestore

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService(); // Instance
  
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getter to access current user
  User? get currentUser => _authService.currentUser;

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
    await _authService.signOut();
    notifyListeners();
  }
}