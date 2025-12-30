import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService(); // Need this to get current User ID

  Stream<QuerySnapshot>? _sessionsStream;

  Stream<QuerySnapshot>? get sessionsStream => _sessionsStream;

  DashboardViewModel() {
    _init();
  }

  void _init() {
    String? userId = _authService.currentUser?.uid;
    if (userId != null) {
      // Fetch sessions assigned to THIS coach
      _sessionsStream = _firestoreService.getCoachSessions(userId);
      notifyListeners();
    }
  }
}