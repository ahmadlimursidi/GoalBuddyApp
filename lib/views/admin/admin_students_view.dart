import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../utils/age_calculator.dart';
import '../../config/theme.dart';

class AdminStudentsView extends StatefulWidget {
  const AdminStudentsView({super.key});

  @override
  State<AdminStudentsView> createState() => _AdminStudentsViewState();
}

class _AdminStudentsViewState extends State<AdminStudentsView> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  DateTime? _selectedDOB;
  String _selectedAgeGroup = 'Little Kicks';
  String _filterAgeGroup = 'All';
  bool _isLoading = false;
  bool _showAddForm = false;

  @override
  void dispose() {
    _nameController.dispose();
    _parentEmailController.dispose();
    _parentPhoneController.dispose();
    _medicalNotesController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDOB() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDOB ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDOB) {
      setState(() {
        _selectedDOB = picked;
        // Calculate age group based on DOB
        double age = AgeCalculator.calculateAgeInYears(_selectedDOB!);
        _selectedAgeGroup = AgeCalculator.getAgeGroupForChild(age);
      });
    }
  }

  Future<void> _registerStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Register the student with Firestore
      bool success = await _firestoreService.registerStudent(
        name: _nameController.text.trim(),
        parentEmail: _parentEmailController.text.trim(),
        parentPhone: _parentPhoneController.text.trim(),
        dateOfBirth: _selectedDOB!,
        medicalNotes: _medicalNotesController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear the form and hide it
        _nameController.clear();
        _parentEmailController.clear();
        _parentPhoneController.clear();
        _medicalNotesController.clear();
        setState(() {
          _selectedDOB = null;
          _isLoading = false;
          _showAddForm = false;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error registering student. Please check the details and try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error registering student: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter and Add Student Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Age Group Filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Filter by Age Group',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _filterAgeGroup,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _filterAgeGroup = newValue;
                        });
                      }
                    },
                    items: <String>['All', 'Little Kicks', 'Junior Kickers', 'Mighty Kickers', 'Mega Kickers']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                // Add Student Button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAddForm = !_showAddForm;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  child: Text(
                    _showAddForm ? 'Cancel' : 'Add Student',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Add Student Form
          if (_showAddForm)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Student Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Student Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the student name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date of Birth
                        TextFormField(
                          controller: _dobController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.cake),
                          ),
                          onTap: () async {
                            await _selectDOB();
                            if (_selectedDOB != null) {
                              _dobController.text = DateFormat('dd/MM/yyyy').format(_selectedDOB!);
                            }
                          },
                          validator: (value) {
                            if (_selectedDOB == null) {
                              return 'Please select date of birth';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Calculated Age Group (read-only)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.school, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Age Group: $_selectedAgeGroup',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Parent Email
                        TextFormField(
                          controller: _parentEmailController,
                          decoration: const InputDecoration(
                            labelText: 'Parent Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter parent email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Parent Phone
                        TextFormField(
                          controller: _parentPhoneController,
                          decoration: const InputDecoration(
                            labelText: 'Parent Phone',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter parent phone number';
                            }
                            if (value.length < 10) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Medical Notes
                        TextFormField(
                          controller: _medicalNotesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Medical Notes',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.medical_services),
                            hintText: 'Any medical conditions or notes...',
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Register Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _registerStudent,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.primaryRed,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'Save Student',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Students List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _filterAgeGroup == 'All'
                  ? _firestoreService.getStudents()
                  : _firestoreService.getStudentsByAgeGroup(_filterAgeGroup),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No students registered yet.'));
                }

                // Sort students by name
                var students = List.from(snapshot.data!.docs);
                students.sort((a, b) {
                  var aName = (a.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? '';
                  var bName = (b.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? '';
                  return aName.compareTo(bName);
                });

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      var studentDoc = students[index];
                      var studentData = studentDoc.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryRed,
                            child: Icon(Icons.child_care, color: Colors.white),
                          ),
                          title: Text(studentData['name'] ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DOB: ${DateFormat('dd/MM/yyyy').format(
                                (studentData['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now()
                              )}'),
                              Text('Age Group: ${studentData['ageGroup'] ?? 'Unknown'}'),
                              Text('Parent: ${studentData['parentEmail'] ?? 'No email'}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () {
                              _showStudentDetails(studentData);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(Map<String, dynamic> studentData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(studentData['name'] ?? 'Student Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Date of Birth: ${DateFormat('dd/MM/yyyy').format(
                  (studentData['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now()
                )}'),
                Text('Age Group: ${studentData['ageGroup'] ?? 'Unknown'}'),
                Text('Parent Email: ${studentData['parentEmail'] ?? 'N/A'}'),
                Text('Parent Phone: ${studentData['parentPhone'] ?? 'N/A'}'),
                if (studentData['medicalNotes'] != null && studentData['medicalNotes'].isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('\nMedical Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(studentData['medicalNotes']),
                    ],
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}