import 'dart:math';
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
  
  // Controllers
  final _nameController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State
  DateTime? _selectedDOB;
  String _selectedAgeGroup = 'Little Kicks';
  String _filterAgeGroup = 'All';
  bool _isLoading = false;
  bool _showAddForm = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _parentEmailController.dispose();
    _parentPhoneController.dispose();
    _medicalNotesController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDOB() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDOB ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryRed,
              onPrimary: Colors.white,
              onSurface: AppTheme.darkText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDOB) {
      setState(() {
        _selectedDOB = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
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
      bool success = await _firestoreService.registerStudent(
        name: _nameController.text.trim(),
        parentEmail: _parentEmailController.text.trim(),
        parentPhone: _parentPhoneController.text.trim(),
        dateOfBirth: _selectedDOB!,
        medicalNotes: _medicalNotesController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (success && mounted) {
        _showSuccessSnackBar('Student registered successfully!');
        _clearForm();
      } else if (mounted) {
        _showErrorSnackBar('Error registering student. Please check details.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _parentEmailController.clear();
    _parentPhoneController.clear();
    _medicalNotesController.clear();
    _passwordController.clear();
    _dobController.clear();
    setState(() {
      _selectedDOB = null;
      _showAddForm = false;
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _generateRandomPassword() {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%&*';
    final Random random = Random();
    String password = '';

    password += 'abcdefghijklmnopqrstuvwxyz'[random.nextInt(26)];
    password += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[random.nextInt(26)];
    password += '0123456789'[random.nextInt(10)];
    password += '!@#\$%&*'[random.nextInt(7)];

    int length = 8 + random.nextInt(5);
    for (int i = password.length; i < length; i++) {
      password += chars[random.nextInt(chars.length)];
    }

    List<String> passwordList = password.split('');
    passwordList.shuffle();
    return passwordList.join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Manage Students"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _showAddForm = !_showAddForm;
          });
        },
        backgroundColor: AppTheme.primaryRed,
        icon: Icon(_showAddForm ? Icons.close : Icons.person_add, color: Colors.white),
        label: Text(
          _showAddForm ? "Cancel" : "Add Student",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 1. Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryRed, Color(0xFFC41A1F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Class Roster",
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text(
                  "All Students",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // 2. Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Section
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: _buildAddStudentForm(),
                    crossFadeState: _showAddForm ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),

                  if (_showAddForm) const SizedBox(height: 24),

                  // Filter Section
                  _buildFilterDropdown(),
                  
                  const SizedBox(height: 16),

                  // Students List
                  StreamBuilder<QuerySnapshot>(
                    stream: _filterAgeGroup == 'All'
                        ? _firestoreService.getStudents()
                        : _firestoreService.getStudentsByAgeGroup(_filterAgeGroup),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyState();
                      }

                      var students = List.from(snapshot.data!.docs);
                      students.sort((a, b) {
                        var aName = (a.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? '';
                        var bName = (b.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? '';
                        return aName.compareTo(bName);
                      });

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          var studentDoc = students[index];
                          var studentData = studentDoc.data() as Map<String, dynamic>;
                          studentData['id'] = studentDoc.id; // Add document ID to data
                          return _buildStudentCard(studentData);
                        },
                      );
                    },
                  ),
                  
                  // Bottom padding for FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterAgeGroup,
          isExpanded: true,
          icon: const Icon(Icons.filter_list, color: AppTheme.primaryRed),
          style: const TextStyle(color: AppTheme.darkText, fontSize: 16, fontWeight: FontWeight.w500),
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
    );
  }

  Widget _buildAddStudentForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("New Student Registration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => setState(() => _showAddForm = false),
                )
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            _buildTextField(controller: _nameController, label: 'Student Name', icon: Icons.person),
            const SizedBox(height: 16),
            
            // DOB Picker
            TextFormField(
              controller: _dobController,
              readOnly: true,
              onTap: _selectDOB,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.cake, color: Colors.grey),
              ),
              validator: (val) => _selectedDOB == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Age Group Display
            if (_selectedDOB != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.pitchGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.pitchGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school, color: AppTheme.pitchGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Assigned Group: $_selectedAgeGroup',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.pitchGreen),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            const Text("Parent Information", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildTextField(controller: _parentEmailController, label: 'Parent Email', icon: Icons.email, isEmail: true),
            const SizedBox(height: 16),
            _buildTextField(controller: _parentPhoneController, label: 'Parent Phone', icon: Icons.phone, isPhone: true),
            const SizedBox(height: 16),
            
            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: 'Parent Account Password',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                    IconButton(
                      icon: const Icon(Icons.autorenew, color: AppTheme.primaryRed),
                      onPressed: () {
                        setState(() {
                          _passwordController.text = _generateRandomPassword();
                          _passwordVisible = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
              validator: (val) => (val == null || val.length < 6) ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 16),
            
            _buildTextField(controller: _medicalNotesController, label: 'Medical Notes (Optional)', icon: Icons.medical_services, maxLines: 3),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Register Student", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isEmail = false,
    bool isPhone = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isPhone ? TextInputType.phone : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        prefixIcon: Icon(icon, color: Colors.grey),
      ),
      validator: (value) {
        if (maxLines > 1) return null; // Optional fields
        if (value == null || value.isEmpty) return 'Required';
        if (isEmail && !value.contains('@')) return 'Invalid Email';
        if (isPhone && value.length < 9) return 'Invalid Phone';
        return null;
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> data) {
    // Check if there are medical notes to show a warning icon
    bool hasMedical = data['medicalNotes'] != null && data['medicalNotes'].toString().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  data['name'] != null && data['name'].isNotEmpty ? data['name'][0].toUpperCase() : 'S',
                  style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          data['name'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasMedical) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.medical_services, size: 14, color: Colors.orange),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.pitchGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      data['ageGroup'] ?? 'Unknown',
                      style: const TextStyle(fontSize: 11, color: AppTheme.pitchGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          data['parentEmail'] ?? 'No Parent Email',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.grey),
                  onPressed: () => _showStudentDetails(data),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editStudent(data);
                    } else if (value == 'delete') {
                      _deleteStudent(data);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: AppTheme.primaryRed, size: 20),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          SizedBox(width: 12),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.school_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No students found",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(Map<String, dynamic> studentData) {
    String? studentId = studentData['id'] as String?;

    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load student profile'), backgroundColor: Colors.red),
      );
      return;
    }

    // Navigate to student profile view
    Navigator.pushNamed(
      context,
      '/student_profile',
      arguments: {
        'studentId': studentId,
        'studentName': studentData['name'] ?? 'Student',
        'isPresent': true,
        'isNew': false,
        'parentContact': studentData['parentEmail'] ?? studentData['parentPhone'] ?? 'N/A',
        'medicalNotes': studentData['medicalNotes'] ?? 'N/A',
      },
    );
  }

  void _editStudent(Map<String, dynamic> studentData) {
    String? studentId = studentData['id'] as String?;
    if (studentId == null) {
      _showErrorSnackBar('Unable to edit student');
      return;
    }

    // Pre-fill form with existing data
    _nameController.text = studentData['name'] ?? '';
    _parentEmailController.text = studentData['parentEmail'] ?? '';
    _parentPhoneController.text = studentData['parentPhone'] ?? '';
    _medicalNotesController.text = studentData['medicalNotes'] ?? '';

    if (studentData['dateOfBirth'] != null) {
      _selectedDOB = (studentData['dateOfBirth'] as Timestamp).toDate();
      _dobController.text = DateFormat('dd/MM/yyyy').format(_selectedDOB!);
      double age = AgeCalculator.calculateAgeInYears(_selectedDOB!);
      _selectedAgeGroup = AgeCalculator.getAgeGroupForChild(age);
    }

    // Show edit dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit, color: AppTheme.primaryRed),
            SizedBox(width: 12),
            Text('Edit Student'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(controller: _nameController, label: 'Student Name', icon: Icons.person),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: _selectDOB,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.cake, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(controller: _parentEmailController, label: 'Parent Email', icon: Icons.email, isEmail: true),
              const SizedBox(height: 12),
              _buildTextField(controller: _parentPhoneController, label: 'Parent Phone', icon: Icons.phone, isPhone: true),
              const SizedBox(height: 12),
              _buildTextField(controller: _medicalNotesController, label: 'Medical Notes', icon: Icons.medical_services, maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.trim().isEmpty) {
                _showErrorSnackBar('Name is required');
                return;
              }

              try {
                await FirebaseFirestore.instance.collection('students').doc(studentId).update({
                  'name': _nameController.text.trim(),
                  'parentEmail': _parentEmailController.text.trim(),
                  'parentPhone': _parentPhoneController.text.trim(),
                  'medicalNotes': _medicalNotesController.text.trim(),
                  if (_selectedDOB != null) 'dateOfBirth': Timestamp.fromDate(_selectedDOB!),
                  if (_selectedDOB != null) 'ageGroup': _selectedAgeGroup,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                if (mounted) {
                  Navigator.pop(context);
                  _showSuccessSnackBar('Student updated successfully!');
                  _clearForm();
                }
              } catch (e) {
                _showErrorSnackBar('Error updating student: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(Map<String, dynamic> studentData) {
    String? studentId = studentData['id'] as String?;
    String studentName = studentData['name'] ?? 'this student';

    if (studentId == null) {
      _showErrorSnackBar('Unable to delete student');
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Student'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete $studentName?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will permanently remove the student and all their data.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Delete student document
                await FirebaseFirestore.instance.collection('students').doc(studentId).delete();

                if (mounted) {
                  Navigator.pop(context);
                  _showSuccessSnackBar('Student deleted successfully');
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  _showErrorSnackBar('Error deleting student: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

}