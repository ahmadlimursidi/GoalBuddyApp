import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/drill_data.dart';

class Drill {
  final String id;
  final String title;
  final String instructions;
  final String equipment;
  final String category;
  final int durationSeconds;
  final String progressionEasier;
  final String progressionHarder;
  final String learningGoals;
  final String? animationUrl; // URL to uploaded animation file (Lottie, video, image, GIF)
  final String? animationJson; // JSON string of AI-generated DrillAnimationData
  final String? visualType; // "animation", "video", "image", "gif", or null
  final int sortOrder; // For sorting drills in the session

  Drill({
    required this.id,
    required this.title,
    required this.instructions,
    required this.equipment,
    required this.category,
    required this.durationSeconds,
    required this.progressionEasier,
    required this.progressionHarder,
    required this.learningGoals,
    this.animationUrl,
    this.animationJson,
    this.visualType,
    required this.sortOrder,
  });

  // Factory constructor to create a Drill from a Map
  factory Drill.fromMap(Map<String, dynamic> data, {String? id}) {
    return Drill(
      id: id ?? '',
      title: data['title'] ?? '',
      instructions: data['instructions'] ?? '',
      equipment: data['equipment'] ?? '',
      category: data['category'] ?? 'Technical',
      durationSeconds: (data['durationSeconds'] ?? data['duration'] ?? 300).toInt(), // Default 5 minutes
      progressionEasier: data['progressionEasier'] ?? data['progression_easier'] ?? '',
      progressionHarder: data['progressionHarder'] ?? data['progression_harder'] ?? '',
      learningGoals: data['learningGoals'] ?? data['learning_goals'] ?? '',
      animationUrl: data['animationUrl'],
      animationJson: data['animationJson'],
      visualType: data['visualType'],
      sortOrder: data['sortOrder'] ?? data['sort_order'] ?? 0,
    );
  }
}

class ActiveSessionViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // State
  bool _isLoading = true;
  List<Drill> _drills = [];
  int _currentDrillIndex = 0;
  String? _pdfUrl;        // PDF URL from template
  String? _pdfFileName;   // PDF filename from template

  // Timer State
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isPaused = true;
  int _totalDurationSeconds = 0;

  // Getters
  bool get isLoading => _isLoading;
  List<Drill> get drills => _drills;
  int get currentDrillIndex => _currentDrillIndex;
  Drill? get currentDrill => _drills.isNotEmpty ? _drills[_currentDrillIndex] : null;
  String? get pdfUrl => _pdfUrl;
  String? get pdfFileName => _pdfFileName;

  int get remainingSeconds => _remainingSeconds;
  bool get isPaused => _isPaused;

  // Calculate progress (0.0 to 1.0) for the circular indicator
  double get progress {
    if (currentDrill == null || currentDrill!.durationSeconds == 0) return 0.0;
    return 1.0 - (_remainingSeconds / currentDrill!.durationSeconds);
  }

  String get timerText {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // Check if we're on the last drill
  bool get isLastDrill => _currentDrillIndex == _drills.length - 1;

  // Check if all drills are completed (on last drill and timer is done)
  bool get isSessionComplete => isLastDrill && _remainingSeconds == 0;

  // --- LOGIC ---

  // Load drills based on the session ID (from sessions collection)
  Future<void> loadSession(String sessionId) async {
    debugPrint("ViewModel loading session for sessionId: '$sessionId'");
    _isLoading = true;
    _isPaused = true;
    _timer?.cancel();
    notifyListeners();

    try {
      // Get the session by ID from the sessions collection
      final sessionDoc = await _firestoreService.getSession(sessionId);
      final sessionData = sessionDoc.data() as Map<String, dynamic>?;

      if (sessionData == null) {
        throw Exception("Session not found");
      }

      // Check if PDF URL is directly in the session (copied from template when session was created)
      _pdfUrl = sessionData['pdfUrl']?.toString();
      _pdfFileName = sessionData['pdfFileName']?.toString();

      // Check if drills are embedded in the session
      if (sessionData['drills'] != null && sessionData['drills'] is List) {
        debugPrint('📥 Loading drills from embedded session data');
        // Load drills directly from the session
        _drills = (sessionData['drills'] as List).asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> drillData = entry.value as Map<String, dynamic>;

          debugPrint('📥 Loading drill ${index + 1}: ${drillData['title']}');
          debugPrint('   - animationJson length: ${drillData['animationJson']?.toString().length ?? 0}');
          debugPrint('   - animationUrl: ${drillData['animationUrl'] ?? "null"}');
          debugPrint('   - visualType: ${drillData['visualType'] ?? "null"}');

          return Drill(
            id: "drill_$index",
            title: drillData['title'] ?? '',
            instructions: drillData['instructions'] ?? '',
            equipment: drillData['equipment'] ?? '',
            category: _getCategoryFromIndex(index),
            durationSeconds: int.tryParse(drillData['duration']?.toString() ?? '') != null
                ? int.parse(drillData['duration'].toString()) * 60 // Convert minutes to seconds
                : 300, // Default to 5 minutes if parsing fails
            progressionEasier: drillData['progression_easier'] ?? '',
            progressionHarder: drillData['progression_harder'] ?? '',
            learningGoals: drillData['learning_goals'] ?? '',
            animationUrl: drillData['animationUrl'],
            animationJson: drillData['animationJson'],
            visualType: drillData['visualType'],
            sortOrder: index,
          );
        }).toList();
      } else {
        // Fallback: Load from template if drills are not embedded
        debugPrint('📥 Loading drills from template (fallback)');
        String? templateId = sessionData['templateId'];
        if (templateId == null) {
          throw Exception("No drills found and no template ID in session");
        }

        final template = await _firestoreService.getSessionTemplateById(templateId);
        if (template == null) {
          throw Exception("Session template not found");
        }

        // Load PDF metadata from template if not already loaded from session
        _pdfUrl ??= template.pdfUrl;
        _pdfFileName ??= template.pdfFileName;

        _drills = template.drills.asMap().entries.map((entry) {
          int index = entry.key;
          DrillData drillData = entry.value;

          debugPrint('📥 Loading drill ${index + 1} from template: ${drillData.title}');
          debugPrint('   - animationJson length: ${drillData.animationJson?.length ?? 0}');
          debugPrint('   - animationUrl: ${drillData.animationUrl ?? "null"}');
          debugPrint('   - visualType: ${drillData.visualType ?? "null"}');

          return Drill(
            id: "drill_$index",
            title: drillData.title,
            instructions: drillData.instructions,
            equipment: drillData.equipment,
            category: _getCategoryFromIndex(index),
            durationSeconds: int.tryParse(drillData.duration) != null
                ? int.parse(drillData.duration) * 60
                : 300,
            progressionEasier: drillData.progressionEasier,
            progressionHarder: drillData.progressionHarder,
            learningGoals: drillData.learningGoals,
            animationUrl: drillData.animationUrl,
            animationJson: drillData.animationJson,
            visualType: drillData.visualType,
            sortOrder: index,
          );
        }).toList();
      }

      if (_drills.isNotEmpty) {
        _currentDrillIndex = 0;
        _remainingSeconds = _drills[0].durationSeconds;
        _totalDurationSeconds = _drills[0].durationSeconds;
      }
    } catch (e) {
      print("Error loading session: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to get category based on drill index
  String _getCategoryFromIndex(int index) {
    const categories = [
      'Intro',
      'Warm Up', 
      'Technical',
      'Match/Game'
    ];
    return categories[index % categories.length];
  }

  void toggleTimer() {
    if (_isPaused) {
      _startTimer();
    } else {
      _pauseTimer();
    }
  }

  void _startTimer() {
    _isPaused = false;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        // Drill Finished!
        _pauseTimer();
        // Optional: Auto-advance or play sound here
      }
    });
  }

  void _pauseTimer() {
    _isPaused = true;
    _timer?.cancel();
    notifyListeners();
  }

  void nextDrill() {
    if (_currentDrillIndex < _drills.length - 1) {
      _currentDrillIndex++;
      _resetDrill();
    }
  }

  void previousDrill() {
    if (_currentDrillIndex > 0) {
      _currentDrillIndex--;
      _resetDrill();
    }
  }

  void _resetDrill() {
    _pauseTimer();
    if (currentDrill != null) {
      _remainingSeconds = currentDrill!.durationSeconds;
      _totalDurationSeconds = currentDrill!.durationSeconds;
    }
    notifyListeners();
  }

  // Finish the session and mark it as completed in Firestore
  Future<bool> finishSession(String sessionId) async {
    try {
      _pauseTimer();
      await _firestoreService.completeSession(sessionId);
      debugPrint("Session $sessionId marked as Completed");
      return true;
    } catch (e) {
      debugPrint("Error finishing session: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}