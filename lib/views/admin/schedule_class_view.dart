import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../view_models/admin_view_model.dart';
import '../../config/theme.dart';
import '../../models/drill_data.dart';
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
  String? _selectedCoachId;
  String _selectedTemplateName = '';
  String _selectedTemplateAgeGroup = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear previous selections when the view is built
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
    // Access the ViewModel
    final viewModel = Provider.of<AdminViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule Class", style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Schedule Class", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // 1. Template Selector
              StreamBuilder<List<SessionTemplate>>(
                stream: viewModel.getSessionTemplates(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  
                  List<SessionTemplate> templates = snapshot.data ?? [];
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Select Template", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Session Template",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.list),
                        ),
                        initialValue: _selectedTemplateId,
                        items: templates.map((template) {
                          return DropdownMenuItem<String>(
                            value: template.id,
                            child: Text("${template.title} (${template.ageGroup})"),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              _selectedTemplateId = value;
                              // Find the selected template to get its name and age group
                              SessionTemplate? selectedTemplate = templates.firstWhere(
                                (template) => template.id == value,
                                orElse: () => SessionTemplate.blank(),
                              );
                              _selectedTemplateName = selectedTemplate.title;
                              _selectedTemplateAgeGroup = selectedTemplate.ageGroup;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a template';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Display selected template details if one is selected
                      if (_selectedTemplateId != null && _selectedTemplateId!.isNotEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Selected: $_selectedTemplateName",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Age Group: $_selectedTemplateAgeGroup",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // 2. Coach Selector
              StreamBuilder<QuerySnapshot>(
                stream: viewModel.getCoaches(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  
                  List<DocumentSnapshot> coaches = snapshot.data?.docs ?? [];
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Assign Coach", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Select Coach",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        initialValue: _selectedCoachId,
                        items: coaches.map((coach) {
                          Map<String, dynamic> data = coach.data() as Map<String, dynamic>;
                          return DropdownMenuItem<String>(
                            value: coach.id,
                            child: Text(data['name'] ?? data['email'] ?? 'Unknown'),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              _selectedCoachId = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a coach';
                          }
                          return null;
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // 3. Venue Input
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(
                  labelText: "Venue / Location",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a venue';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 4. Date Picker (TextFormField)
              FormField<DateTime>(
                initialValue: viewModel.selectedDate,
                validator: (value) {
                  if (value == null) return 'Please select a date';
                  return null;
                },
                builder: (FormFieldState<DateTime> state) {
                  return InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: viewModel.selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        viewModel.setDate(picked);
                        state.didChange(picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Select Date',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.primaryRed),
                        errorText: state.errorText,
                      ),
                      child: Text(
                        viewModel.selectedDate != null
                            ? "${viewModel.selectedDate!.day}/${viewModel.selectedDate!.month}/${viewModel.selectedDate!.year}"
                            : '',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 5. Time Picker (TextFormField)
              FormField<TimeOfDay>(
                initialValue: viewModel.selectedTime,
                validator: (value) {
                  if (value == null) return 'Please select a start time';
                  return null;
                },
                builder: (FormFieldState<TimeOfDay> state) {
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
                      decoration: InputDecoration(
                        labelText: 'Select Start Time',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.access_time, color: AppTheme.primaryRed),
                        errorText: state.errorText,
                      ),
                      child: Text(
                        viewModel.selectedTime != null
                            ? viewModel.selectedTime!.format(context)
                            : '',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // 6. Schedule Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        // Validate form
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        bool success = await viewModel.scheduleClass(
                          templateId: _selectedTemplateId!,
                          coachId: _selectedCoachId!,
                          venue: _venueController.text.trim(),
                        );

                        if (success && context.mounted) {
                          Navigator.pop(context); // Go back to dashboard
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Class Scheduled Successfully!"), backgroundColor: Colors.green),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to schedule class. Please try again."), backgroundColor: Colors.red),
                          );
                        }
                      },
                  child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Schedule Class", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}