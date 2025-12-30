import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../view_models/attendance_view_model.dart';
import '../../models/attendance_model.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    // Load students for the current session after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map && arguments.containsKey('sessionId')) {
        _sessionId = arguments['sessionId'] as String?;
        if (_sessionId != null) {
          final attendanceViewModel = Provider.of<AttendanceViewModel>(context, listen: false);
          attendanceViewModel.loadStudents(_sessionId!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if sessionId was provided
    if (_sessionId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Class Register"),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Error: Session ID not provided',
                style: TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Please access this screen from an active session',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Class Register"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Attendance Saved!")),
              );
            },
            child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
          )
        ],
      ),
      body: Consumer<AttendanceViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${viewModel.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadStudents(_sessionId!),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Class Summary Header
              _buildSummaryCard(viewModel),
              const SizedBox(height: 24),

              // Student List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Students (${viewModel.totalStudents})",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      "${viewModel.presentStudents}/${viewModel.totalStudents} Present",
                      style: TextStyle(
                        color: AppTheme.pitchGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Expanded list of students from the ViewModel
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.students.length,
                  itemBuilder: (context, index) {
                    final student = viewModel.students[index];
                    return _buildStudentTile(
                      context,
                      student,
                      (isPresent) => viewModel.updateStudentAttendance(student.id, isPresent),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      // Floating Summary showing "X of Y present"
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryRed.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppTheme.pitchGreen, size: 16),
              const SizedBox(width: 8),
              Consumer<AttendanceViewModel>(
                builder: (context, viewModel, child) {
                  return Text(
                    "${viewModel.presentStudents} of ${viewModel.totalStudents} Present",
                    style: TextStyle(
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AttendanceViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                viewModel.totalStudents.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Text("Total"),
            ],
          ),
          // Pitch Green for Present
          Column(
            children: [
              Text(
                viewModel.presentStudents.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.pitchGreen,
                ),
              ),
              const Text("Present"),
            ],
          ),
          // Orange for New Starters (Critical for retention)
          Column(
            children: [
              Text(
                viewModel.students.where((s) => s.isNew).length.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.orange,
                ),
              ),
              const Text("New"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile(
    BuildContext context,
    StudentAttendance student,
    Function(bool) onAttendanceChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: student.isPresent ? Colors.white : Colors.grey[50],
      child: ListTile(
        onTap: () {
          // This connects to the Student Profile View
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: student.isPresent ? Colors.black : Colors.grey,
              ),
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
          student.medicalNotes, // Showing age or medical notes
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: student.isPresent,
            activeColor: AppTheme.pitchGreen,
            shape: RoundedRectangleBorder( // Changed to square checkbox
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: AppTheme.primaryRed, width: 2),
            ),
            onChanged: (val) {
              if (val != null) {
                onAttendanceChanged(val);
              }
            },
          ),
        ),
      ),
    );
  }
}