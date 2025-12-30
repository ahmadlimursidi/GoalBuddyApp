import 'dart:async';
import 'package:flutter/material.dart';
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
  final String? animationUrl; // New field for animation URL
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

  // --- LOGIC ---

  // Load drills based on the session ID
  Future<void> loadSession(String sessionId) async {
    debugPrint("ViewModel loading session for sessionId: '$sessionId'"); // <-- DEBUG PRINT
    _isLoading = true;
    _isPaused = true;
    _timer?.cancel();
    notifyListeners();

    try {
      // Get the scheduled class by ID
      final scheduledClassDoc = await _firestoreService.getScheduledClass(sessionId);
      final scheduledClassData = scheduledClassDoc.data() as Map<String, dynamic>?;
      
      if (scheduledClassData == null) {
        throw Exception("Scheduled class not found");
      }

      // Get the template ID from the scheduled class
      String? templateId = scheduledClassData['templateId'];
      if (templateId == null) {
        throw Exception("Template ID not found in scheduled class");
      }

      // Get the session template by ID
      final template = await _firestoreService.getSessionTemplateById(templateId);
      if (template == null) {
        throw Exception("Session template not found");
      }

      // Map the template drills to Drill objects
      _drills = template.drills.asMap().entries.map((entry) {
        int index = entry.key;
        DrillData drillData = entry.value;
        return Drill(
          id: "drill_$index", // Generate a temporary ID
          title: drillData.title,
          instructions: drillData.instructions,
          equipment: drillData.equipment,
          category: _getCategoryFromIndex(index), // Map index to category
          durationSeconds: int.tryParse(drillData.duration) != null 
              ? int.parse(drillData.duration) * 60 // Convert minutes to seconds
              : 300, // Default to 5 minutes if parsing fails
          progressionEasier: drillData.progressionEasier,
          progressionHarder: drillData.progressionHarder,
          learningGoals: drillData.learningGoals,
          animationUrl: drillData.animationUrl,
          sortOrder: index, // Use index as sort order
        );
      }).toList();

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}