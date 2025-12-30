import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../view_models/student_parent_view_model.dart';

class AttendanceHistoryWidget extends StatelessWidget {
  final StudentParentViewModel viewModel;

  const AttendanceHistoryWidget({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    List<SessionAttendanceRecord> recentHistory = viewModel.recentAttendanceHistory;

    if (recentHistory.isEmpty) {
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
                    Icons.history,
                    color: AppTheme.primaryRed,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Attendance History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No attendance history",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "Attendance records will appear here",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show only the last 5 records for the history view
    List<SessionAttendanceRecord> recentRecords = recentHistory.take(5).toList();

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
                  Icons.history,
                  color: AppTheme.primaryRed,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Recent Attendance",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                for (int i = 0; i < recentRecords.length; i++)
                  Column(
                    children: [
                      _buildAttendanceHistoryItem(recentRecords[i]),
                      if (i < recentRecords.length - 1) const SizedBox(height: 12),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceHistoryItem(SessionAttendanceRecord record) {
    Color statusColor = record.isPresent ? Colors.green : Colors.red;
    IconData statusIcon = record.isPresent ? Icons.check_circle : Icons.cancel;
    String statusText = record.isPresent ? "Attended" : "Absent";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.className,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  record.date != null
                      ? "${record.date!.day}/${record.date!.month}/${record.date!.year}"
                      : "Date Unknown",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}