import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/drill_data.dart';
import '../models/session_template.dart';

class AdminViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoaded = false;

  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;

  // Form State
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedAgeGroup;

  // Getters for UI
  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;
  String? get selectedAgeGroup => _selectedAgeGroup;

  // Dropdown Options
  final List<String> ageGroups = [
    'Little Kicks',
    'Junior Kickers',
    'Mighty Kickers',
    'Mega Kickers'
  ];

  void setDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setTime(TimeOfDay? time) {
    _selectedTime = time;
    notifyListeners();
  }

  void setAgeGroup(String? value) {
    _selectedAgeGroup = value;
    notifyListeners();
  }

  // Mark as loaded when data is ready
  void markAsLoaded() {
    _isLoaded = true;
    notifyListeners();
  }

  // Mark as not loaded when navigating away
  void markAsNotLoaded() {
    _isLoaded = false;
    notifyListeners();
  }

  Future<bool> createClass({
    required String venue,
    String? title,
    String? duration,
    String? instructions,
    String? equipment,
    String? progressionEasier,
    String? progressionHarder,
    String? learningGoals,
  }) async {
    if (_selectedDate == null || _selectedTime == null || _selectedAgeGroup == null || venue.isEmpty) {
      return false; // Validation Failed
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Combine Date and Time into one DateTime object
      final DateTime fullDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // 2. Get Current User (To assign the class to yourself for the demo)
      String coachId = _authService.currentUser?.uid ?? '';

      // 3. Generate Class Name based on Age Group (e.g., "Junior Kickers (2.5 - 3.5yrs)")
      String className = title ?? _generateClassName(_selectedAgeGroup!);

      // 4. Parse duration if provided, otherwise use default
      int durationMinutes = int.tryParse(duration ?? '') ??
                           (_selectedAgeGroup == 'Mega Kickers' ? 50 : 45);

      // 5. Save to Firestore
      await _firestoreService.createSessionWithDetails(
        className: className,
        venue: venue,
        dateTime: fullDateTime,
        ageGroup: _selectedAgeGroup!,
        coachId: coachId,
        durationMinutes: durationMinutes,
        instructions: instructions,
        equipment: equipment,
        progressionEasier: progressionEasier,
        progressionHarder: progressionHarder,
        learningGoals: learningGoals,
      );

      _isLoading = false;
      notifyListeners();
      return true; // Success

    } catch (e) {
      print("Error creating class: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _generateClassName(String group) {
    switch (group) {
      case 'Little Kicks': return 'Little Kicks (1.5 - 2.5yrs)';
      case 'Junior Kickers': return 'Junior Kickers (2.5 - 3.5yrs)';
      case 'Mighty Kickers': return 'Mighty Kickers (3.5 - 5yrs)';
      case 'Mega Kickers': return 'Mega Kickers (5 - 8yrs)';
      default: return group;
    }
  }

  // Create class with list of drills (for backward compatibility)
  Future<bool> createClassWithDrills({
    required String venue,
    required String title,
    required String duration,
    required String badgeFocus,
    required List<DrillData> drills,
  }) async {
    if (_selectedDate == null || _selectedTime == null || _selectedAgeGroup == null || venue.isEmpty) {
      return false; // Validation Failed
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Combine Date and Time into one DateTime object
      final DateTime fullDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // 2. Get Current User (To assign the class to yourself for the demo)
      String coachId = _authService.currentUser?.uid ?? '';

      // 3. Parse duration if provided
      int durationMinutes = int.tryParse(duration) ?? 45;

      // 4. Convert DrillData list to map format for Firestore
      List<Map<String, dynamic>> drillsData = drills.map<Map<String, dynamic>>((drill) {
        return <String, dynamic>{
          'title': drill.title,
          'duration': drill.duration,
          'instructions': drill.instructions,
          'equipment': drill.equipment,
          'progression_easier': drill.progressionEasier,
          'progression_harder': drill.progressionHarder,
          'learning_goals': drill.learningGoals,
        };
      }).toList();

      // 5. Save to Firestore
      await _firestoreService.createSessionWithDrills(
        className: title,
        venue: venue,
        dateTime: fullDateTime,
        ageGroup: _selectedAgeGroup!,
        coachId: coachId,
        durationMinutes: durationMinutes,
        badgeFocus: badgeFocus,
        drills: drillsData,
      );

      _isLoading = false;
      notifyListeners();
      return true; // Success

    } catch (e) {
      print("Error creating class with drills: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Create a session template (content without scheduling)
  Future<bool> createTemplate({
    required String title,
    required String ageGroup,
    required String badgeFocus,
    required List<DrillData> drills,
    String? pdfUrl,
    String? pdfFileName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String coachId = _authService.currentUser?.uid ?? '';

      // Convert DrillData list to map format for Firestore
      List<Map<String, dynamic>> drillsData = drills.map<Map<String, dynamic>>((drill) {
        return <String, dynamic>{
          'title': drill.title,
          'duration': drill.duration,
          'instructions': drill.instructions,
          'equipment': drill.equipment,
          'progression_easier': drill.progressionEasier,
          'progression_harder': drill.progressionHarder,
          'learning_goals': drill.learningGoals,
          'animationUrl': drill.animationUrl,
          'animationJson': drill.animationJson,
          'visualType': drill.visualType,
        };
      }).toList();

      // Create the session template with PDF metadata
      await _firestoreService.createSessionTemplate(
        title: title,
        ageGroup: ageGroup,
        badgeFocus: badgeFocus,
        drills: drillsData,
        createdBy: coachId,
        pdfUrl: pdfUrl,
        pdfFileName: pdfFileName,
      );

      _isLoading = false;
      notifyListeners();
      return true; // Success

    } catch (e) {
      print("Error creating session template: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get all session templates for the session library
  Stream<List<SessionTemplate>> getSessionTemplates() {
    return _firestoreService.getSessionTemplates().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SessionTemplate.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Register a new coach
  Future<bool> registerCoach({
    required String name,
    required String email,
    required String phone,
    required int age,
    required double ratePerHour,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // For backward compatibility, use the legacy function
      await _firestoreService.registerCoachLegacy(
        name: name,
        email: email,
        phone: phone,
        age: age,
        ratePerHour: ratePerHour,
      );

      _isLoading = false;
      notifyListeners();
      return true; // Success
    } catch (e) {
      print("Error registering coach: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get all coaches for admin view
  Stream<QuerySnapshot> getCoaches() {
    return _firestoreService.getCoaches();
  }

  // Schedule a class using a template
  Future<bool> scheduleClass({
    required String templateId,
    required String leadCoachId,
    String? assistantCoachId,
    required String venue,
  }) async {
    if (_selectedDate == null || _selectedTime == null || venue.isEmpty) {
      return false; // Validation Failed
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Get template details from Firestore
      final template = await _firestoreService.getSessionTemplateById(templateId);

      if (template == null) {
        print("Error: Template with ID $templateId not found.");
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Combine Date and Time into one DateTime object
      final DateTime fullDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // 3. Use default duration based on age group, as it's not in the template model
      int durationMinutes = (template.ageGroup == 'Mega Kickers' ? 50 : 45);

      // 4. Convert drills from template to map format
      List<Map<String, dynamic>> drillsData = template.drills.map<Map<String, dynamic>>((drill) {
        return <String, dynamic>{
          'title': drill.title,
          'duration': drill.duration,
          'instructions': drill.instructions,
          'equipment': drill.equipment,
          'progression_easier': drill.progressionEasier,
          'progression_harder': drill.progressionHarder,
          'learning_goals': drill.learningGoals,
          'animationUrl': drill.animationUrl,
        };
      }).toList();

      // 5. Call Firestore service to create the scheduled class with drills
      String sessionId = await _firestoreService.createScheduledClassWithDrills(
        templateId: templateId,
        className: template.title,
        venue: venue,
        dateTime: fullDateTime,
        ageGroup: template.ageGroup,
        leadCoachId: leadCoachId,
        assistantCoachId: assistantCoachId,
        durationMinutes: durationMinutes,
        badgeFocus: template.badgeFocus,
        drills: drillsData,
      );

      // 6. Auto-assign all students with matching age group to this class
      await _firestoreService.autoAssignStudentsToClass(
        sessionId: sessionId,
        ageGroup: template.ageGroup,
      );

      _isLoading = false;
      notifyListeners();
      return true; // Success

    } catch (e) {
      print("Error scheduling class: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}