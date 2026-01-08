import 'package:flutter/foundation.dart';
import '../models/drill_data.dart';
import '../services/firestore_service.dart';

/// Extended drill model with session template context
class TemplateActivity {
  final String activityId; // Unique ID combining template ID and drill index
  final String templateId;
  final String templateTitle;
  final String ageGroup;
  final String badgeFocus;
  final DrillData drillData;
  final int orderInTemplate;
  final String? pdfUrl;        // PDF URL if template was created from PDF
  final String? pdfFileName;   // Original PDF filename

  TemplateActivity({
    required this.activityId,
    required this.templateId,
    required this.templateTitle,
    required this.ageGroup,
    required this.badgeFocus,
    required this.drillData,
    required this.orderInTemplate,
    this.pdfUrl,
    this.pdfFileName,
  });

  // Infer drill type from title/instructions (intro, warm up, game, technical, etc.)
  String get drillType {
    final title = drillData.title.toLowerCase();
    final instructions = drillData.instructions.toLowerCase();
    final combined = '$title $instructions';

    if (combined.contains('intro') || combined.contains('muster') || combined.contains('welcome')) {
      return 'Intro / Muster';
    } else if (combined.contains('warm up') || combined.contains('warmup')) {
      return 'Warm Up';
    } else if (combined.contains('game') || combined.contains('match') || combined.contains('fun')) {
      return 'Match / Game';
    } else if (combined.contains('technical') || combined.contains('skill') || combined.contains('ball mastery')) {
      return 'Technical / Skill';
    } else {
      return 'Other';
    }
  }
}

class DrillLibraryViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<TemplateActivity> _allActivities = [];
  List<TemplateActivity> _filteredActivities = [];

  // Filter states
  String _selectedAgeGroup = 'All';
  String _selectedBadgeFocus = 'All';
  String _selectedDrillType = 'All';
  String _selectedTemplate = 'All';
  String _searchQuery = '';

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<TemplateActivity> get allActivities => _allActivities;
  List<TemplateActivity> get filteredActivities => _filteredActivities;
  String get selectedAgeGroup => _selectedAgeGroup;
  String get selectedBadgeFocus => _selectedBadgeFocus;
  String get selectedDrillType => _selectedDrillType;
  String get selectedTemplate => _selectedTemplate;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all activities from session templates (real-time)
  Stream<List<TemplateActivity>> watchActivities() {
    return _firestoreService.getSessionTemplates().map((snapshot) {
      final activities = <TemplateActivity>[];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final templateId = doc.id;
        final templateTitle = data['title'] ?? 'Untitled Template';
        final ageGroup = data['ageGroup'] ?? 'Unknown';
        final badgeFocus = data['badgeFocus'] ?? 'Unknown';
        final pdfUrl = data['pdfUrl']?.toString();
        final pdfFileName = data['pdfFileName']?.toString();
        final drills = data['drills'] as List<dynamic>? ?? [];

        for (int i = 0; i < drills.length; i++) {
          final drillMap = drills[i] as Map<String, dynamic>;
          final drillData = DrillData(
            title: drillMap['title'] ?? 'Untitled Drill',
            duration: drillMap['duration']?.toString() ?? '5',
            instructions: drillMap['instructions'] ?? '',
            equipment: drillMap['equipment'] ?? '',
            progressionEasier: drillMap['progression_easier'] ?? '',
            progressionHarder: drillMap['progression_harder'] ?? '',
            learningGoals: drillMap['learning_goals'] ?? '',
            animationUrl: drillMap['animationUrl'],
          );

          activities.add(TemplateActivity(
            activityId: '${templateId}_$i',
            templateId: templateId,
            templateTitle: templateTitle,
            ageGroup: ageGroup,
            badgeFocus: badgeFocus,
            drillData: drillData,
            orderInTemplate: i + 1,
            pdfUrl: pdfUrl,
            pdfFileName: pdfFileName,
          ));
        }
      }

      return activities;
    });
  }

  // Load all activities from session templates
  Future<void> loadActivities() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestoreService.getSessionTemplates().first;
      _allActivities = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final templateId = doc.id;
        final templateTitle = data['title'] ?? 'Untitled Template';
        final ageGroup = data['ageGroup'] ?? 'Unknown';
        final badgeFocus = data['badgeFocus'] ?? 'Unknown';
        final pdfUrl = data['pdfUrl']?.toString();
        final pdfFileName = data['pdfFileName']?.toString();
        final drills = data['drills'] as List<dynamic>? ?? [];

        for (int i = 0; i < drills.length; i++) {
          final drillMap = drills[i] as Map<String, dynamic>;
          final drillData = DrillData(
            title: drillMap['title'] ?? 'Untitled Drill',
            duration: drillMap['duration']?.toString() ?? '5',
            instructions: drillMap['instructions'] ?? '',
            equipment: drillMap['equipment'] ?? '',
            progressionEasier: drillMap['progression_easier'] ?? '',
            progressionHarder: drillMap['progression_harder'] ?? '',
            learningGoals: drillMap['learning_goals'] ?? '',
            animationUrl: drillMap['animationUrl'],
          );

          _allActivities.add(TemplateActivity(
            activityId: '${templateId}_$i',
            templateId: templateId,
            templateTitle: templateTitle,
            ageGroup: ageGroup,
            badgeFocus: badgeFocus,
            drillData: drillData,
            orderInTemplate: i + 1,
            pdfUrl: pdfUrl,
            pdfFileName: pdfFileName,
          ));
        }
      }

      // Apply current filters
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter methods
  void setSelectedAgeGroup(String ageGroup) {
    _selectedAgeGroup = ageGroup;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedBadgeFocus(String badgeFocus) {
    _selectedBadgeFocus = badgeFocus;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedDrillType(String drillType) {
    _selectedDrillType = drillType;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedTemplate(String template) {
    _selectedTemplate = template;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void resetFilters() {
    _selectedAgeGroup = 'All';
    _selectedBadgeFocus = 'All';
    _selectedDrillType = 'All';
    _selectedTemplate = 'All';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Apply all filters
  void _applyFilters() {
    _filteredActivities = _allActivities.where((activity) {
      bool matchesAgeGroup = _selectedAgeGroup == 'All' || activity.ageGroup == _selectedAgeGroup;
      bool matchesBadgeFocus = _selectedBadgeFocus == 'All' || activity.badgeFocus == _selectedBadgeFocus;
      bool matchesDrillType = _selectedDrillType == 'All' || activity.drillType == _selectedDrillType;
      bool matchesTemplate = _selectedTemplate == 'All' || activity.templateTitle == _selectedTemplate;
      bool matchesSearch = _searchQuery.isEmpty ||
          activity.drillData.title.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesAgeGroup && matchesBadgeFocus && matchesDrillType && matchesTemplate && matchesSearch;
    }).toList();
  }

  // Get unique filter options
  List<String> get ageGroups {
    final groups = _allActivities.map((a) => a.ageGroup).toSet().toList();
    groups.sort();
    return ['All', ...groups];
  }

  List<String> get badgeFocuses {
    final focuses = _allActivities.map((a) => a.badgeFocus).toSet().toList();
    focuses.sort();
    return ['All', ...focuses];
  }

  List<String> get drillTypes {
    final types = _allActivities.map((a) => a.drillType).toSet().toList();
    types.sort();
    return ['All', ...types];
  }

  List<String> get templateTitles {
    final titles = _allActivities.map((a) => a.templateTitle).toSet().toList();
    titles.sort();
    return ['All', ...titles];
  }

  // Refresh data
  Future<void> refresh() async {
    await loadActivities();
  }
}
