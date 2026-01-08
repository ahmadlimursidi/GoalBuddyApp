import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../view_models/admin_view_model.dart';
import '../../config/theme.dart';
import '../../models/session_template.dart';

class ScheduleClassView extends StatefulWidget {
  const ScheduleClassView({super.key});

  @override
  State<ScheduleClassView> createState() => _ScheduleClassViewState();
}

class _ScheduleClassViewState extends State<ScheduleClassView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _venueController = TextEditingController();
  
  String? _selectedTemplateId;
  String? _selectedLeadCoachId;
  String? _selectedAssistantCoachId;
  String _selectedTemplateName = '';
  String _selectedTemplateAgeGroup = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<AdminViewModel>(context, listen: false);
      viewModel.setDate(null);
      viewModel.setTime(null);
    });
  }

  @override
  void dispose() {
    _venueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: const Text("Schedule Class"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
                  "New Session",
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text(
                  "Class Details",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // 2. Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SECTION 1: TEMPLATE SELECTION ---
                    _buildSectionHeader("Curriculum", Icons.library_books),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedTemplateId != null) ...[
                            // Selected State
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.pitchGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.pitchGreen),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: AppTheme.pitchGreen),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedTemplateName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkText),
                                        ),
                                        Text(
                                          _selectedTemplateAgeGroup,
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        _selectedTemplateId = null;
                                        _selectedTemplateName = '';
                                        _selectedTemplateAgeGroup = '';
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                          ] else ...[
                            // Search State
                            TextField(
                              decoration: _inputDecoration("Search Templates...", Icons.search),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 180,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[200]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: StreamBuilder<List<SessionTemplate>>(
                                stream: viewModel.getSessionTemplates(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));

                                  List<SessionTemplate> templates = snapshot.data ?? [];
                                  final filteredTemplates = templates.where((template) =>
                                    template.title.toLowerCase().contains(_searchQuery) ||
                                    template.ageGroup.toLowerCase().contains(_searchQuery)
                                  ).toList();

                                  if (filteredTemplates.isEmpty) {
                                    return const Center(child: Text("No templates found", style: TextStyle(color: Colors.grey)));
                                  }

                                  return ListView.separated(
                                    itemCount: filteredTemplates.length,
                                    separatorBuilder: (ctx, i) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final template = filteredTemplates[index];
                                      return ListTile(
                                        title: Text(template.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                        subtitle: Text(template.ageGroup, style: const TextStyle(fontSize: 12)),
                                        trailing: const Icon(Icons.chevron_right, size: 16),
                                        onTap: () {
                                          setState(() {
                                            _selectedTemplateId = template.id;
                                            _selectedTemplateName = template.title;
                                            _selectedTemplateAgeGroup = template.ageGroup;
                                          });
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- SECTION 2: LOGISTICS ---
                    _buildSectionHeader("Logistics", Icons.access_time_filled),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _cardDecoration(),
                      child: Column(
                        children: [
                          // Date Picker
                          FormField<DateTime>(
                            initialValue: viewModel.selectedDate,
                            validator: (val) => val == null ? 'Required' : null,
                            builder: (state) {
                              return InkWell(
                                onTap: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: viewModel.selectedDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(primary: AppTheme.primaryRed),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    viewModel.setDate(picked);
                                    state.didChange(picked);
                                  }
                                },
                                child: InputDecorator(
                                  decoration: _inputDecoration("Date", Icons.calendar_today, errorText: state.errorText),
                                  child: Text(
                                    viewModel.selectedDate != null
                                        ? "${viewModel.selectedDate!.day}/${viewModel.selectedDate!.month}/${viewModel.selectedDate!.year}"
                                        : "Select Date",
                                    style: TextStyle(color: viewModel.selectedDate != null ? AppTheme.darkText : Colors.grey[600]),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Time Picker
                          FormField<TimeOfDay>(
                            initialValue: viewModel.selectedTime,
                            validator: (val) => val == null ? 'Required' : null,
                            builder: (state) {
                              return InkWell(
                                onTap: () async {
                                  TimeOfDay? picked = await showTimePicker(
                                    context: context,
                                    initialTime: viewModel.selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
                                  );
                                  if (picked != null) {
                                    viewModel.setTime(picked);
                                    state.didChange(picked);
                                  }
                                },
                                child: InputDecorator(
                                  decoration: _inputDecoration("Start Time", Icons.access_time, errorText: state.errorText),
                                  child: Text(
                                    viewModel.selectedTime != null ? viewModel.selectedTime!.format(context) : "Select Time",
                                    style: TextStyle(color: viewModel.selectedTime != null ? AppTheme.darkText : Colors.grey[600]),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Venue
                          TextFormField(
                            controller: _venueController,
                            decoration: _inputDecoration("Venue / Location", Icons.location_on),
                            validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- SECTION 3: COACHING STAFF ---
                    _buildSectionHeader("Staffing", Icons.people_alt),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _cardDecoration(),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: viewModel.getCoaches(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                          
                          List<DocumentSnapshot> coaches = snapshot.data?.docs ?? [];
                          
                          return Column(
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: _inputDecoration("Lead Coach", Icons.person),
                                value: _selectedLeadCoachId,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: coaches.map((coach) {
                                  Map<String, dynamic> data = coach.data() as Map<String, dynamic>;
                                  return DropdownMenuItem(
                                    value: coach.id,
                                    child: Text(data['name'] ?? 'Unknown', overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedLeadCoachId = val),
                                validator: (val) => val == null ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                decoration: _inputDecoration("Assistant Coach (Optional)", Icons.person_outline),
                                value: _selectedAssistantCoachId,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text("None")),
                                  ...coaches.map((coach) {
                                    Map<String, dynamic> data = coach.data() as Map<String, dynamic>;
                                    return DropdownMenuItem(
                                      value: coach.id,
                                      child: Text(data['name'] ?? 'Unknown', overflow: TextOverflow.ellipsis),
                                    );
                                  }),
                                ],
                                onChanged: (val) => setState(() => _selectedAssistantCoachId = val),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : () async {
                          if (_selectedTemplateId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a template"), backgroundColor: Colors.red));
                            return;
                          }
                          if (!_formKey.currentState!.validate()) return;
                          
                          if (viewModel.selectedDate == null || viewModel.selectedTime == null) {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Date and Time are required"), backgroundColor: Colors.red));
                             return;
                          }

                          bool success = await viewModel.scheduleClass(
                            templateId: _selectedTemplateId!,
                            leadCoachId: _selectedLeadCoachId!,
                            assistantCoachId: _selectedAssistantCoachId,
                            venue: _venueController.text.trim(),
                          );

                          if (success && context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Class Scheduled Successfully!"), backgroundColor: Colors.green));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: AppTheme.primaryRed.withOpacity(0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: viewModel.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Schedule Class", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryRed),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {String? errorText}) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryRed)),
      prefixIcon: Icon(icon, color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}