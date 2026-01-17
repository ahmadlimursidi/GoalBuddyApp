import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../view_models/auth_view_model.dart';
import '../../services/firestore_service.dart';
import '../finance/finance_view.dart';
import '../admin/class_details_view.dart';
import '../admin/session_templates_list_view.dart';
import '../admin/past_sessions_view.dart';
import '../analytics/admin_analytics_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _currentIndex = 0;
  bool _isFabExpanded = false;
  final LayerLink _layerLink = LayerLink();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    // Determine current view
    Widget currentView;
    if (_currentIndex == 0) {
      currentView = _buildDashboardContent(authViewModel);
    } else if (_currentIndex == 1) {
      currentView = _buildFinanceContent();
    } else {
      currentView = _buildAnalyticsContent();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authViewModel.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
          ),
        ],
      ),

      // Expandable FAB
      floatingActionButton: CompositedTransformTarget(
        link: _layerLink,
        child: FloatingActionButton(
          backgroundColor: AppTheme.primaryRed,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: _toggleFab,
          child: Icon(
            _isFabExpanded ? Icons.close : Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: currentView,

      // Modern Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryRed,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: "Finance"),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: "Analytics"),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(AuthViewModel authViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Curved Gradient Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryRed, Color(0xFFC41A1F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Icon(Icons.admin_panel_settings, color: AppTheme.primaryRed),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Welcome, Manager",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Branch Overview",
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Manage schedules, staff, and students.",
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
              ),
            ],
          ),
        ),

        // 2. Content Body
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Scheduled Classes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                ),
                const SizedBox(height: 16),
                
                // Class List Stream
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService.getAllScheduledClasses(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyState();
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: docs.length,
                        padding: const EdgeInsets.only(bottom: 80), // Space for FAB
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          return _buildClassCard(context, doc.id, data);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(BuildContext context, String docId, Map<String, dynamic> data) {
    String rawStatus = data['status'] ?? 'SCHEDULED';
    String status = rawStatus.toUpperCase();
    Color statusColor = (status == 'ACTIVE' || status == 'COMPLETED') ? AppTheme.pitchGreen : Colors.orange;
    bool isCompleted = status == 'COMPLETED';

    return Dismissible(
      key: Key(docId),
      direction: isCompleted ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.pitchGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.archive, color: Colors.white, size: 32),
            SizedBox(height: 4),
            Text(
              'Archive',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.archive, color: AppTheme.pitchGreen),
                  SizedBox(width: 8),
                  Text('Archive Session'),
                ],
              ),
              content: Text('Move "${data['className'] ?? 'this session'}" to past sessions?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pitchGreen),
                  child: const Text('Archive'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        try {
          await _firestoreService.archiveSession(docId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session archived successfully'),
                backgroundColor: AppTheme.pitchGreen,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error archiving session: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Container(
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClassDetailsView(
                    classId: docId,
                    classData: data,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryRed),
                  ),
                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['className'] ?? 'Unknown Class',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                data['venue'] ?? 'Unknown Venue',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Badge & Actions
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                            padding: EdgeInsets.zero,
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editClass(context, docId, data);
                              } else if (value == 'delete') {
                                _deleteClass(context, docId, data);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryRed),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                    SizedBox(width: 8),
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
                ],
              ),
            ),
          ),
        ),
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
            child: Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            "No classes scheduled",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the + button to create a new class.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceContent() {
    return const FinanceView();
  }

  Widget _buildAnalyticsContent() {
    return const AdminAnalyticsView();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });

    if (_isFabExpanded) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true, // Fix for flexible height
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5)),
                ],
              ),
              child: SingleChildScrollView( // Fix for Overflow
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                    _buildBottomSheetItem(Icons.library_add, "Create Template", "Build new curriculum", () {
                      Navigator.pop(context);
                      _resetFab();
                      Navigator.pushNamed(context, '/create_session_template');
                    }),
                    _buildBottomSheetItem(Icons.playlist_add_check, "Manage Sessions", "View all templates", () {
                      Navigator.pop(context);
                      _resetFab();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SessionTemplatesListView()));
                    }),
                    _buildBottomSheetItem(Icons.calendar_month, "Schedule Class", "Assign template to coach", () {
                      Navigator.pop(context);
                      _resetFab();
                      Navigator.pushNamed(context, '/schedule_class');
                    }),
                    _buildBottomSheetItem(Icons.archive, "Past Sessions", "View archived sessions", () {
                      Navigator.pop(context);
                      _resetFab();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PastSessionsView()));
                    }),
                    const Divider(height: 1),
                    _buildBottomSheetItem(Icons.school, "Manage Students", "View roster", () {
                      Navigator.pop(context);
                      _resetFab();
                      Navigator.pushNamed(context, '/admin_students');
                    }),
                    _buildBottomSheetItem(Icons.group, "Manage Coaches", "View staff", () {
                      Navigator.pop(context);
                      _resetFab();
                      Navigator.pushNamed(context, '/admin_coaches');
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ).then((_) => _resetFab());
    }
  }

  void _resetFab() {
    if (mounted) {
      setState(() {
        _isFabExpanded = false;
      });
    }
  }

  Widget _buildBottomSheetItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryRed),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkText)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _editClass(BuildContext context, String classId, Map<String, dynamic> classData) {
    final TextEditingController venueController = TextEditingController(text: classData['venue'] ?? '');
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // Parse existing timestamp
    if (classData['startTime'] != null) {
      final timestamp = classData['startTime'] as Timestamp;
      final dateTime = timestamp.toDate();
      selectedDate = dateTime;
      selectedTime = TimeOfDay.fromDateTime(dateTime);
    }

    String? selectedLeadCoachId = classData['coachId'] ?? classData['leadCoachId'];
    String? selectedAssistantCoachId = classData['assistantCoachId'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.edit, color: AppTheme.primaryRed),
              SizedBox(width: 8),
              Text('Edit Class'),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Venue
                  TextField(
                    controller: venueController,
                    decoration: const InputDecoration(
                      labelText: 'Venue',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Picker
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        selectedDate != null
                            ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                            : "Select Date",
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time Picker
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        selectedTime != null ? selectedTime!.format(context) : "Select Time",
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Coach Selection
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService.getCoaches(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      List<DocumentSnapshot> coaches = snapshot.data?.docs ?? [];

                      return Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: selectedLeadCoachId,
                            decoration: const InputDecoration(
                              labelText: 'Lead Coach',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            items: coaches.map((coach) {
                              Map<String, dynamic> data = coach.data() as Map<String, dynamic>;
                              return DropdownMenuItem(
                                value: coach.id,
                                child: Text(data['name'] ?? 'Unknown'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedLeadCoachId = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: selectedAssistantCoachId,
                            decoration: const InputDecoration(
                              labelText: 'Assistant Coach (Optional)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            items: [
                              const DropdownMenuItem(value: null, child: Text("None")),
                              ...coaches.map((coach) {
                                Map<String, dynamic> data = coach.data() as Map<String, dynamic>;
                                return DropdownMenuItem(
                                  value: coach.id,
                                  child: Text(data['name'] ?? 'Unknown'),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedAssistantCoachId = value;
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (venueController.text.trim().isEmpty || selectedDate == null || selectedTime == null || selectedLeadCoachId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                try {
                  final startDateTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );

                  await FirebaseFirestore.instance.collection('sessions').doc(classId).update({
                    'venue': venueController.text.trim(),
                    'startTime': Timestamp.fromDate(startDateTime),
                    'coachId': selectedLeadCoachId,
                    'leadCoachId': selectedLeadCoachId,
                    'assistantCoachId': selectedAssistantCoachId,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Class updated successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating class: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteClass(BuildContext context, String classId, Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Class'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${classData['className'] ?? 'this class'}"?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. All attendance records for this class will be lost.',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryRed),
                ),
              );

              try {
                await _firestoreService.deleteSession(classId);

                if (context.mounted) {
                  // Close loading indicator
                  Navigator.pop(context);
                  // Close delete confirmation dialog
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Class deleted successfully'),
                      backgroundColor: AppTheme.pitchGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  // Close loading indicator
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting class: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}