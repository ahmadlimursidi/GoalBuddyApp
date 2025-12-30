import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../config/theme.dart';
import '../view_models/student_parent_view_model.dart';

class AttendanceReportWidget extends StatelessWidget {
  final StudentParentViewModel viewModel;
  final bool isDetailedView;

  const AttendanceReportWidget({
    super.key,
    required this.viewModel,
    this.isDetailedView = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate attendance statistics
    int totalClasses = viewModel.attendanceRecords.length;
    int attendedClasses = viewModel.attendanceRecords.where((record) => record.isPresent).length;
    int absentClasses = totalClasses - attendedClasses;
    double attendancePercentage = totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0.0;
    
    // Calculate attendance for different time periods
    DateTime now = DateTime.now();
    DateTime oneMonthAgo = now.subtract(const Duration(days: 30));
    DateTime threeMonthsAgo = now.subtract(const Duration(days: 90));
    
    List<SessionAttendanceRecord> recentMonth = viewModel.attendanceRecords
        .where((record) => record.date != null && record.date!.isAfter(oneMonthAgo))
        .toList();
    
    List<SessionAttendanceRecord> recentThreeMonths = viewModel.attendanceRecords
        .where((record) => record.date != null && record.date!.isAfter(threeMonthsAgo))
        .toList();
    
    double recentMonthAttendance = recentMonth.isNotEmpty 
        ? (recentMonth.where((record) => record.isPresent).length / recentMonth.length) * 100 
        : 0.0;
    
    double recentThreeMonthsAttendance = recentThreeMonths.isNotEmpty 
        ? (recentThreeMonths.where((record) => record.isPresent).length / recentThreeMonths.length) * 100 
        : 0.0;

    if (totalClasses == 0) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.insert_chart_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                "No Attendance Data",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Attend a few classes to see attendance reports",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                  Icons.analytics,
                  color: AppTheme.primaryRed,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Attendance Report",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Overall attendance with percentage
            Row(
              children: [
                CircularPercentIndicator(
                  radius: 70.0,
                  lineWidth: 8.0,
                  animation: true,
                  percent: attendancePercentage / 100,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${attendancePercentage.toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Text(
                        "Overall",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
                      _buildStatItem("Total Classes", totalClasses.toString()),
                      const SizedBox(height: 8),
                      _buildStatItem("Attended", attendedClasses.toString(), Colors.green),
                      const SizedBox(height: 8),
                      _buildStatItem("Absent", absentClasses.toString(), Colors.red),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Time-based attendance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeAttendanceItem("This Month", recentMonthAttendance),
                _buildTimeAttendanceItem("3 Months", recentThreeMonthsAttendance),
              ],
            ),
            
            if (isDetailedView) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Attendance calendar view (simplified)
              const Text(
                "Monthly Breakdown",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildMonthlyBreakdown(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, [Color? color]) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: (color ?? AppTheme.primaryRed).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color ?? AppTheme.primaryRed,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeAttendanceItem(String period, double percentage) {
    Color color = percentage >= 80 
        ? Colors.green 
        : percentage >= 60 
            ? Colors.orange 
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            "${percentage.toStringAsFixed(0)}%",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          Text(
            period,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdown() {
    // Group attendance by month for the past 3 months
    Map<String, Map<String, int>> monthlyStats = {};
    DateTime now = DateTime.now();
    
    // Initialize the last 3 months
    for (int i = 0; i < 3; i++) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      String monthKey = "${month.month}/${month.year}";
      monthlyStats[monthKey] = {"total": 0, "attended": 0};
    }
    
    // Calculate stats for each month
    for (var record in viewModel.attendanceRecords) {
      if (record.date != null) {
        String monthKey = "${record.date!.month}/${record.date!.year}";
        if (monthlyStats.containsKey(monthKey)) {
          monthlyStats[monthKey]!["total"] = monthlyStats[monthKey]!["total"]! + 1;
          if (record.isPresent) {
            monthlyStats[monthKey]!["attended"] = monthlyStats[monthKey]!["attended"]! + 1;
          }
        }
      }
    }
    
    return Column(
      children: monthlyStats.entries.map((entry) {
        int total = entry.value["total"] ?? 0;
        int attended = entry.value["attended"] ?? 0;
        double percentage = total > 0 ? (attended / total) * 100 : 0.0;
        
        Color color = percentage >= 80 
            ? Colors.green 
            : percentage >= 60 
                ? Colors.orange 
                : Colors.red;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Text(entry.key),
              ),
              Text(
                "$attended/$total",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${percentage.toStringAsFixed(0)}%",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}