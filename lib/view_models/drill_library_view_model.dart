import 'package:flutter/foundation.dart';
import '../models/drill_model.dart';
import '../services/firestore_service.dart';

class DrillLibraryViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Drill> _allDrills = [];
  List<Drill> _filteredDrills = [];
  String _selectedAgeGroup = 'All';
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Drill> get allDrills => _allDrills;
  List<Drill> get filteredDrills => _filteredDrills;
  String get selectedAgeGroup => _selectedAgeGroup;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all drills from Firestore
  Future<void> loadDrills() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final drillMaps = await _firestoreService.getDrills();
      _allDrills = drillMaps
          .where((d) => d is Map<String, dynamic>) // Filter out null documents
          .map((d) => Drill.fromMap(d))
          .toList();

      // Apply current filter
      _applyFilter();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter drills based on selected age group
  void setSelectedAgeGroup(String ageGroup) {
    _selectedAgeGroup = ageGroup;
    _applyFilter();
    notifyListeners();
  }

  // Apply the current filter to the drills
  void _applyFilter() {
    if (_selectedAgeGroup == 'All') {
      _filteredDrills = _allDrills;
    } else {
      _filteredDrills = _allDrills
          .where((drill) => drill.ageGroup == _selectedAgeGroup)
          .toList();
    }
  }

  // Get all unique age groups from the drills
  List<String> get ageGroups {
    final ageGroups = _allDrills
        .map((drill) => drill.ageGroup)
        .toSet()
        .toList();
    
    // Add 'All' as the first option
    return ['All', ...ageGroups];
  }

  // Get drills by category for a specific age group
  List<Drill> getDrillsByCategory(String category) {
    return _filteredDrills
        .where((drill) => drill.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  // Get all unique categories from the filtered drills
  List<String> get categories {
    return _filteredDrills
        .map((drill) => drill.category)
        .toSet()
        .toList();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadDrills();
  }
}