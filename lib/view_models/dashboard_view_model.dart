import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService(); // Need this to get current User ID

  Stream<QuerySnapshot>? _sessionsStream;
  Stream<QuerySnapshot>? _assistantSessionsStream;

  Stream<QuerySnapshot>? get sessionsStream => _sessionsStream;
  Stream<QuerySnapshot>? get assistantSessionsStream => _assistantSessionsStream;

  String? get currentUserId => _authService.currentUser?.uid;

  DashboardViewModel() {
    _init();
  }

  void _init() {
    String? userId = _authService.currentUser?.uid;
    if (userId != null) {
      // Fetch sessions assigned to THIS coach as lead
      _sessionsStream = _firestoreService.getCoachSessions(userId);
      // Fetch sessions assigned to THIS coach as assistant
      _assistantSessionsStream = _firestoreService.getAssistantCoachSessions(userId);
      notifyListeners();
    }
  }

  void refreshDashboard() {
    String? userId = _authService.currentUser?.uid;
    if (userId != null) {
      // Refresh sessions assigned to THIS coach as lead
      _sessionsStream = _firestoreService.getCoachSessions(userId);
      // Refresh sessions assigned to THIS coach as assistant
      _assistantSessionsStream = _firestoreService.getAssistantCoachSessions(userId);
      notifyListeners();
    }
  }
}