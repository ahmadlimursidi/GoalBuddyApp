import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../config/theme.dart';
import '../view_models/student_parent_view_model.dart';

class AttendanceProgressWidget extends StatelessWidget {
  final StudentParentViewModel viewModel;

  const AttendanceProgressWidget({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate attendance statistics
    int totalClasses = viewModel.attendanceRecords.length;
    int attendedClasses = viewModel.attendanceRecords.where((record) => record.isPresent).length;
    double attendancePercentage = totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: AppTheme.primaryRed,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Attendance Progress",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Overall attendance percentage
            Row(
              children: [
                CircularPercentIndicator(
                  radius: 60.0,
                  lineWidth: 8.0,
                  animation: true,
                  percent: attendancePercentage / 100,
                  center: Text(
                    "${attendancePercentage.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: attendancePercentage >= 80 
                      ? Colors.green 
                      : attendancePercentage >= 60 
                          ? Colors.orange 
                          : Colors.red,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Overall Attendance",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$attendedClasses of $totalClasses sessions",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Attendance breakdown
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusItem(Icons.check_circle, Colors.green, "Attended", attendedClasses.toString()),
                      _buildStatusItem(Icons.cancel, Colors.red, "Absent", (totalClasses - attendedClasses).toString()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, Color color, String label, String count) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}