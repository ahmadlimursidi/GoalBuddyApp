import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../models/attendance_model.dart';

class StudentListView extends StatefulWidget {
  const StudentListView({super.key});

  @override
  State<StudentListView> createState() => _StudentListViewState();
}

class _StudentListViewState extends State<StudentListView> {
  String _selectedAgeGroup = 'All';
  List<StudentAttendance> _allStudents = [];
  List<StudentAttendance> _filteredStudents = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, String> _studentAgeGroupMap = {}; // Map to store studentId -> ageGroup
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<StudentAttendance> allStudents = [];
      Set<String> uniqueStudentIds = {}; // To avoid duplicate students
      Map<String, String> studentAgeGroupMap = {}; // Map to store studentId -> ageGroup

      // Get students from the main 'students' collection (newly registered students)
      final studentsSnapshot = await FirebaseFirestore.instance.collection('students').get();
      for (var studentDoc in studentsSnapshot.docs) {
        String studentId = studentDoc.id;

        // Only add unique students to prevent duplicates
        if (!uniqueStudentIds.contains(studentId)) {
          final data = studentDoc.data();
          // Create StudentAttendance from the main student data
          allStudents.add(StudentAttendance(
            id: studentId,
            name: data['name'] ?? '',
            isPresent: false, // Default to not present
            isNew: data['createdAt'] != null ?
              DateTime.now().difference(data['createdAt'].toDate()).inDays <= 7 : false, // Mark as new if created within last 7 days
            parentContact: data['parentContact'] ?? '',
            medicalNotes: data['medicalNotes'] ?? '',
            ageGroup: data['ageGroup'] ?? '',
          ));
          uniqueStudentIds.add(studentId);

          // Store age group directly if available
          if (data.containsKey('ageGroup') && data['ageGroup'] != null && data['ageGroup'].toString().isNotEmpty) {
            studentAgeGroupMap[studentId] = data['ageGroup'];
          }
        }
      }

      // Also get students from session collections (existing students)
      // Get all sessions to know the age group for each student
      final sessionsSnapshot = await FirebaseFirestore.instance.collection('sessions').get();
      Map<String, String> sessionIdToAgeGroup = {};

      // First pass: collect session age groups
      for (var sessionDoc in sessionsSnapshot.docs) {
        String sessionId = sessionDoc.id;
        String sessionAgeGroup = sessionDoc.data()['ageGroup'] ?? 'Unknown';
        sessionIdToAgeGroup[sessionId] = sessionAgeGroup;
      }

      // Second pass: get students and assign age groups
      for (var sessionDoc in sessionsSnapshot.docs) {
        String sessionAgeGroup = sessionIdToAgeGroup[sessionDoc.id] ?? 'Unknown';
        final sessionStudentsSnapshot = await sessionDoc.reference.collection('students').get();

        for (var studentDoc in sessionStudentsSnapshot.docs) {
          String studentId = studentDoc.id;

          // Only add unique students to prevent duplicates
          if (!uniqueStudentIds.contains(studentId)) {
            final data = studentDoc.data();
            allStudents.add(StudentAttendance.fromMap(data, studentDoc.id));
            uniqueStudentIds.add(studentId);

            // Store the age group for this student
            studentAgeGroupMap[studentId] = sessionAgeGroup;
          } else {
            // If the student already exists in the list, we can update the age group mapping
            // This handles cases where a student might appear in multiple collections
            if (!studentAgeGroupMap.containsKey(studentId) ||
                studentAgeGroupMap[studentId] == '') {
              studentAgeGroupMap[studentId] = sessionAgeGroup;
            }
          }
        }
      }

      // Update the age group mapping for students from main collection
      for (var entry in studentAgeGroupMap.entries) {
        if (sessionIdToAgeGroup.containsKey(entry.value)) {
          studentAgeGroupMap[entry.key] = sessionIdToAgeGroup[entry.value]!;
        }
      }

      // Also update the ageGroup field in StudentAttendance objects if they have an empty ageGroup
      for (var student in allStudents) {
        if ((student.ageGroup.isEmpty || student.ageGroup == 'Unknown') && studentAgeGroupMap.containsKey(student.id)) {
          // Create a new StudentAttendance with updated age group
          int index = allStudents.indexOf(student);
          allStudents[index] = StudentAttendance(
            id: student.id,
            name: student.name,
            isPresent: student.isPresent,
            isNew: student.isNew,
            parentContact: student.parentContact,
            medicalNotes: student.medicalNotes,
            ageGroup: studentAgeGroupMap[student.id]!,
          );
        }
      }

      setState(() {
        _allStudents = allStudents;
        _filteredStudents = _allStudents;
        _studentAgeGroupMap = studentAgeGroupMap;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterStudents(String ageGroup) {
    setState(() {
      _selectedAgeGroup = ageGroup;
      _applyFilters();
    });
  }

  void _setSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<StudentAttendance> filtered = _allStudents;

    // Apply age group filter
    if (_selectedAgeGroup != 'All') {
      filtered = filtered.where((student) {
        String? mapAgeGroup = _studentAgeGroupMap[student.id];
        String studentAgeGroup = (mapAgeGroup != null && mapAgeGroup.isNotEmpty) ? mapAgeGroup : student.ageGroup;
        return studentAgeGroup == _selectedAgeGroup;
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((student) {
        String query = _searchQuery.toLowerCase();
        return student.name.toLowerCase().contains(query) ||
               (student.parentContact.toLowerCase().contains(query)) ||
               (_studentAgeGroupMap[student.id]?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    _filteredStudents = filtered;
  }

  void _resetFilters() {
    setState(() {
      _selectedAgeGroup = 'All';
      _searchQuery = '';
      _searchController.clear();
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get all unique age groups from the sessions for filtering
    Set<String> ageGroups = {'All'}; // Add 'All' as default

    // Extract age groups from the actual data we've loaded
    for (var student in _allStudents) {
      // Get age group from map, but use student.ageGroup if map value is null or empty
      String? mapAgeGroup = _studentAgeGroupMap[student.id];
      String studentAgeGroup = (mapAgeGroup != null && mapAgeGroup.isNotEmpty) ? mapAgeGroup : student.ageGroup;

      if (studentAgeGroup != 'Unknown' && studentAgeGroup.isNotEmpty) {
        ageGroups.add(studentAgeGroup);
      }
    }

    List<String> sortedAgeGroups = ageGroups.toList()..sort();

    // Check if filters are active
    final hasActiveFilters = _selectedAgeGroup != 'All' || _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Student Directory"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          if (hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Reset Filters',
              onPressed: _resetFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search students...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryRed),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filter Chips (Scrollable)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.filter_list, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'FILTER BY AGE GROUP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: sortedAgeGroups.map((ageGroup) {
                      bool isSelected = _selectedAgeGroup == ageGroup;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(ageGroup),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            _filterStudents(ageGroup);
                          },
                          selectedColor: AppTheme.primaryRed.withOpacity(0.1),
                          checkmarkColor: AppTheme.primaryRed,
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.primaryRed : AppTheme.darkText,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: isSelected ? AppTheme.primaryRed : Colors.transparent),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Results count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Icon(Icons.people_alt, size: 18, color: AppTheme.primaryRed),
                const SizedBox(width: 8),
                Text(
                  '${_filteredStudents.length} Students Found',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkText,
                  ),
                ),
                const Spacer(),
                Text(
                  'From ${_allStudents.length} Total',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Student List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Error: $_errorMessage',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAllStudents,
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredStudents.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = _filteredStudents[index];
                              return _buildStudentCard(context, student);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
              ],
            ),
            child: Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'No students found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search query',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, StudentAttendance student) {
    // Get age group for this student
    String? mapAgeGroup = _studentAgeGroupMap[student.id];
    String studentAgeGroup = (mapAgeGroup != null && mapAgeGroup.isNotEmpty) ? mapAgeGroup : student.ageGroup;
    bool hasMedicalInfo = student.medicalNotes.isNotEmpty && student.medicalNotes.toLowerCase() != 'none';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(context, '/student_profile', arguments: {
              'studentId': student.id,
              'studentName': student.name,
              'isPresent': student.isPresent,
              'isNew': student.isNew,
              'parentContact': student.parentContact,
              'medicalNotes': student.medicalNotes,
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: student.isNew ? Colors.orange.withOpacity(0.1) : AppTheme.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: student.isNew ? Colors.orange : AppTheme.primaryRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and badges
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              student.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (student.isNew) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "NEW",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (hasMedicalInfo) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.medical_services, size: 14, color: Colors.red),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Age group badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.pitchGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.pitchGreen.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.child_care, size: 12, color: AppTheme.pitchGreen),
                            const SizedBox(width: 4),
                            Text(
                              studentAgeGroup,
                              style: const TextStyle(
                                color: AppTheme.pitchGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Parent contact
                      if (student.parentContact.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.contact_phone, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                student.parentContact,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}