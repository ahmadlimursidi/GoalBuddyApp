import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../view_models/dashboard_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../finance/finance_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _currentIndex = 0;
  bool _isFabExpanded = false;
  final LayerLink _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    // Reuse the DashboardViewModel for now to see list of sessions
    // In a real app, you might have a separate AdminDashboardViewModel
    final viewModel = Provider.of<DashboardViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    Widget currentView = _currentIndex == 0
      ? _buildDashboardContent(viewModel, authViewModel)
      : _buildFinanceContent();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: AppTheme.darkText, // Different color to distinguish
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              authViewModel.logout(); // Call the logout method
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // Navigate and clear stack
            },
          ),
        ],
      ),

      // Unified FAB that expands with options
      floatingActionButton: CompositedTransformTarget(
        link: _layerLink,
        child: FloatingActionButton(
          backgroundColor: AppTheme.primaryRed,
          onPressed: _toggleFab,
          child: _isFabExpanded ? const Icon(Icons.close) : const Icon(Icons.add),
        ),
      ),

      // Show expanded menu when FAB is pressed
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: currentView,

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppTheme.primaryRed,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Finance"),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(DashboardViewModel viewModel, AuthViewModel authViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: AppTheme.darkText,
          width: double.infinity,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text("Welcome, Branch Manager", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
               SizedBox(height: 8),
               Text("Manage your branch schedules and coaches here.", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),

        // Add some padding for the list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: viewModel.sessionsStream, // This currently fetches "my" sessions.
            // For admin, you might want "ALL" sessions.
            // For now, it will show sessions created by this admin user.
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No classes scheduled yet.\nTap the + button to create one!", textAlign: TextAlign.center),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today, color: AppTheme.primaryRed),
                      title: Text(data['className'] ?? 'Unknown'),
                      subtitle: Text("${data['venue']} • ${data['status']}"),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceContent() {
    return const FinanceView();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });

    if (_isFabExpanded) {
      // Show the modal bottom sheet with options
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.library_books, color: Colors.red),
                  title: const Text('Create Session Template'),
                  onTap: () {
                    Navigator.pop(context); // Close the modal
                    setState(() {
                      _isFabExpanded = false; // Reset FAB state
                    });
                    Navigator.pushNamed(context, '/create_session_template');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event, color: Colors.red),
                  title: const Text('Schedule Class'),
                  onTap: () {
                    Navigator.pop(context); // Close the modal
                    setState(() {
                      _isFabExpanded = false; // Reset FAB state
                    });
                    Navigator.pushNamed(context, '/schedule_class');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.red),
                  title: const Text('Manage Students'),
                  onTap: () {
                    Navigator.pop(context); // Close the modal
                    setState(() {
                      _isFabExpanded = false; // Reset FAB state
                    });
                    Navigator.pushNamed(context, '/admin_students');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people_alt, color: Colors.red),
                  title: const Text('Manage Coaches'),
                  onTap: () {
                    Navigator.pop(context); // Close the modal
                    setState(() {
                      _isFabExpanded = false; // Reset FAB state
                    });
                    Navigator.pushNamed(context, '/admin_coaches');
                  },
                ),
              ],
            ),
          );
        },
      ).then((_) {
        // This is called when the modal sheet is dismissed
        setState(() {
          _isFabExpanded = false;
        });
      });
    }
  }

}