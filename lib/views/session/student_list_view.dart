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

  @override
  void initState() {
    super.initState();
    _loadAllStudents();
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
          ));
          uniqueStudentIds.add(studentId);

          // Store age group if available (from assignedClassId)
          if (data.containsKey('assignedClassId')) {
            // We'll resolve the age group later when we have all session data
            studentAgeGroupMap[studentId] = data['assignedClassId'];
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

      setState(() {
        _allStudents = allStudents;
        // Create a temporary list with age group annotations so we can filter properly
        _filteredStudents = _allStudents;
        _isLoading = false;
      });

      // Update the age group mapping to use the actual age group names instead of class IDs
      for (var entry in studentAgeGroupMap.entries) {
        if (sessionIdToAgeGroup.containsKey(entry.value)) {
          studentAgeGroupMap[entry.key] = sessionIdToAgeGroup[entry.value]!;
        }
      }

      // Store the map in a class variable for later use in filtering
      _studentAgeGroupMap = studentAgeGroupMap;

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
      if (ageGroup == 'All') {
        _filteredStudents = _allStudents;
      } else {
        // Filter students based on their session's age group using the pre-loaded map
        _filteredStudents = _allStudents.where((student) {
          String studentAgeGroup = _studentAgeGroupMap[student.id] ?? 'Unknown';
          return studentAgeGroup == ageGroup;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get all unique age groups from the sessions for filtering
    Set<String> ageGroups = {'All'}; // Add 'All' as default
    
    // In a real implementation, you'd extract age groups from session data
    // For now, just adding some sample groups
    ageGroups.addAll(['Little Kicks', 'Junior Kickers', 'Mighty Kickers', 'Mega Kickers']);
    List<String> sortedAgeGroups = ageGroups.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Directory"),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Filter Chips (Scrollable)
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: sortedAgeGroups.map((ageGroup) {
                bool isSelected = _selectedAgeGroup == ageGroup;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(ageGroup),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryRed,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.darkText,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryRed : Colors.grey.shade300,
                    ),
                    onSelected: (bool selected) {
                      _filterStudents(ageGroup);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Display count of students found
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_filteredStudents.length} Students",
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  "Tap for details",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Student List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Error: $_errorMessage',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAllStudents,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredStudents.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 60, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  "No students found",
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                Text(
                                  "Try selecting a different age group",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = _filteredStudents[index];
                              return _buildStudentTile(context, student);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile(BuildContext context, StudentAttendance student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: ListTile(
        onTap: () {
          // Navigate to Student Profile View with student information
          Navigator.pushNamed(context, '/student_profile', arguments: {
            'studentId': student.id,
            'studentName': student.name,
            'isPresent': student.isPresent,
            'isNew': student.isNew,
            'parentContact': student.parentContact,
            'medicalNotes': student.medicalNotes,
          });
        },
        leading: CircleAvatar(
          backgroundColor: student.isNew ? Colors.orange : Colors.blue.shade50,
          child: Text(
            student.name.isNotEmpty ? student.name[0] : '?',
            style: TextStyle(
              color: student.isNew ? Colors.white : AppTheme.primaryRed,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              student.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (student.isNew) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "NEW",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ]
          ],
        ),
        subtitle: Text(
          "Age Group: ${student.medicalNotes.isNotEmpty ? 'Has Medical Info' : 'No Medical Info'}",
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}