import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../view_models/analytics_view_model.dart';

class AdminAnalyticsView extends StatelessWidget {
  const AdminAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalyticsViewModel(),
      child: const _AdminAnalyticsContent(),
    );
  }
}

class _AdminAnalyticsContent extends StatelessWidget {
  const _AdminAnalyticsContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AnalyticsViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed))
          : RefreshIndicator(
              onRefresh: viewModel.fetchAnalytics,
              color: AppTheme.primaryRed,
              child: CustomScrollView(
                slivers: [
                  // 1. Modern Header
                  SliverAppBar(
                    expandedHeight: 160.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: AppTheme.darkText,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)], // Professional Dark Teal Gradient
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -20,
                              top: -20,
                              child: Icon(Icons.analytics_outlined, size: 150, color: Colors.white.withOpacity(0.05)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Branch Analytics",
                                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Performance metrics & insights",
                                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. Content Body
                  // Filter Section
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: _buildAgeGroupFilter(context, viewModel),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Key Metrics Grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      // Adjusted aspect ratio to prevent overflow on smaller screens
                      childAspectRatio: 1.2,
                      children: [
                        _buildStatCard(
                          title: "Total Students",
                          value: viewModel.totalStudents.toString(),
                          icon: Icons.people_alt,
                          color: Colors.blue,
                          subtitle: "Active Enrolments",
                        ),
                        _buildStatCard(
                          title: "Attendance Rate",
                          value: "${viewModel.overallAttendanceRate.toStringAsFixed(1)}%",
                          icon: Icons.check_circle,
                          color: viewModel.getAttendanceColor(viewModel.overallAttendanceRate),
                          subtitle: "Average across classes",
                        ),
                        _buildStatCard(
                          title: "Total Classes",
                          value: viewModel.totalClasses.toString(),
                          icon: Icons.class_,
                          color: Colors.orange,
                          subtitle: "Scheduled this cycle",
                        ),
                         _buildStatCard(
                          title: "Sessions Run",
                          value: viewModel.totalSessions.toString(),
                          icon: Icons.history,
                          color: Colors.purple,
                          subtitle: "Completed to date",
                        ),
                      ],
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // Remaining Content
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Capacity & Utilization
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            "Capacity & Utilization",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                          ),
                        ),
                        _buildUtilizationCard(viewModel),

                        const SizedBox(height: 32),

                        // Attendance Breakdown
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            "Attendance by Age Group",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                          ),
                        ),
                        _buildAttendanceList(viewModel),

                        const SizedBox(height: 32),

                        // Student Distribution
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            "Student Distribution",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                          ),
                        ),
                        _buildStudentDistribution(viewModel),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAgeGroupFilter(BuildContext context, AnalyticsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt_rounded, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                "FILTER VIEW",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: viewModel.ageGroups.map((ageGroup) {
                bool isSelected = viewModel.selectedAgeGroup == ageGroup;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(ageGroup),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) viewModel.setAgeGroup(ageGroup);
                    },
                    selectedColor: AppTheme.primaryRed.withOpacity(0.1),
                    checkmarkColor: AppTheme.primaryRed,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryRed : AppTheme.darkText,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top section with Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),

          const Spacer(), // Pushes the text content to the bottom

          // Text content with overflow protection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 9, color: Colors.grey[400]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // New Data Card: Capacity Utilization
  Widget _buildUtilizationCard(AnalyticsViewModel viewModel) {
    double utilization = viewModel.capacityUtilization;
    int utilizationPercent = (utilization * 100).round();

    // Determine status based on utilization
    String status;
    Color statusColor;
    if (utilization >= 0.85) {
      status = "FULL";
      statusColor = Colors.red;
    } else if (utilization >= 0.70) {
      status = "HEALTHY";
      statusColor = Colors.green;
    } else if (utilization >= 0.50) {
      status = "MODERATE";
      statusColor = Colors.orange;
    } else {
      status = "LOW";
      statusColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Class Utilization", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Based on age group capacities", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
              )
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 20,
                    width: constraints.maxWidth * utilization,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: utilization >= 0.85
                            ? [Colors.red, Colors.redAccent]
                            : utilization >= 0.70
                                ? [Colors.green, Colors.lightGreen]
                                : [Colors.blue, Colors.lightBlueAccent],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("0%", style: TextStyle(fontSize: 10, color: Colors.grey[400])),
              Text("$utilizationPercent% Filled", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              Text("100%", style: TextStyle(fontSize: 10, color: Colors.grey[400])),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAttendanceList(AnalyticsViewModel viewModel) {
    final ageGroupAttendance = viewModel.ageGroupAttendance;
    if (ageGroupAttendance.isEmpty) return const Text("No Data");

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ageGroupAttendance.length,
        itemBuilder: (context, index) {
          String ageGroup = ageGroupAttendance.keys.elementAt(index);
          AttendanceData data = ageGroupAttendance.values.elementAt(index);
          Color color = viewModel.getAttendanceColor(data.rate);

          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ageGroup, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                Center(
                  child: Text(
                    "${data.rate.toStringAsFixed(0)}%",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentDistribution(AnalyticsViewModel viewModel) {
    final studentCounts = viewModel.ageGroupStudentCounts;
    if (studentCounts.isEmpty) return const SizedBox();

    final total = studentCounts.values.fold(0, (sum, count) => sum + count);
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.pink];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: studentCounts.entries.toList().asMap().entries.map((entry) {
          int index = entry.key;
          String ageGroup = entry.value.key;
          int count = entry.value.value;
          double percentage = total > 0 ? (count / total) * 100 : 0;
          Color color = colors[index % colors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.circle, size: 10, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(ageGroup, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text("$count students", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[100],
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}