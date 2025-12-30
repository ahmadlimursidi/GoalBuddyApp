import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../view_models/admin_view_model.dart';
import '../../config/theme.dart';
import '../../widgets/pdf_upload_button.dart';
import '../../models/drill_data.dart';

// Drill form card widget (copied from the previous implementation)
class DrillFormCard extends StatefulWidget {
  final DrillData drill;
  final VoidCallback onRemove;
  final int index;

  const DrillFormCard({
    super.key,
    required this.drill,
    required this.onRemove,
    required this.index,
  });

  @override
  State<DrillFormCard> createState() => _DrillFormCardState();
}

class _DrillFormCardState extends State<DrillFormCard> {
  late TextEditingController _titleController;
  late TextEditingController _durationController;
  late TextEditingController _instructionsController;
  late TextEditingController _equipmentController;
  late TextEditingController _progressionEasierController;
  late TextEditingController _progressionHarderController;
  late TextEditingController _learningGoalsController;

  String? _selectedAnimationFile;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with drill data
    _titleController = TextEditingController(text: widget.drill.title);
    _durationController = TextEditingController(text: widget.drill.duration);
    _instructionsController = TextEditingController(text: widget.drill.instructions);
    _equipmentController = TextEditingController(text: widget.drill.equipment);
    _progressionEasierController = TextEditingController(text: widget.drill.progressionEasier);
    _progressionHarderController = TextEditingController(text: widget.drill.progressionHarder);
    _learningGoalsController = TextEditingController(text: widget.drill.learningGoals);

    // Store the animation file name if exists
    if (widget.drill.animationUrl != null && widget.drill.animationUrl!.isNotEmpty) {
      _selectedAnimationFile = widget.drill.animationUrl;
    }

    // Add listeners to update the drill data when text changes
    _titleController.addListener(_updateDrill);
    _durationController.addListener(_updateDrill);
    _instructionsController.addListener(_updateDrill);
    _equipmentController.addListener(_updateDrill);
    _progressionEasierController.addListener(_updateDrill);
    _progressionHarderController.addListener(_updateDrill);
    _learningGoalsController.addListener(_updateDrill);
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateDrill);
    _durationController.removeListener(_updateDrill);
    _instructionsController.removeListener(_updateDrill);
    _equipmentController.removeListener(_updateDrill);
    _progressionEasierController.removeListener(_updateDrill);
    _progressionHarderController.removeListener(_updateDrill);
    _learningGoalsController.removeListener(_updateDrill);

    _titleController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    _equipmentController.dispose();
    _progressionEasierController.dispose();
    _progressionHarderController.dispose();
    _learningGoalsController.dispose();

    super.dispose();
  }

  void _updateDrill() {
    widget.drill.title = _titleController.text;
    widget.drill.duration = _durationController.text;
    widget.drill.instructions = _instructionsController.text;
    widget.drill.equipment = _equipmentController.text;
    widget.drill.progressionEasier = _progressionEasierController.text;
    widget.drill.progressionHarder = _progressionHarderController.text;
    widget.drill.learningGoals = _learningGoalsController.text;
  }

  Future<void> _uploadAnimation() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      // In a real implementation, you would upload the file to Firebase Storage
      // For now, just store the filename as a placeholder
      setState(() {
        _selectedAnimationFile = result.files.first.name;
        // In a real implementation, you would store the actual URL from Firebase Storage
        widget.drill.animationUrl = result.files.first.name; // Placeholder
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Activity ${widget.index + 1}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Activity Title",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an activity title';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Duration (minutes)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter duration';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _instructionsController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Instructions",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter instructions';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _equipmentController,
              decoration: const InputDecoration(
                labelText: "Equipment",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sports_soccer),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter required equipment';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _progressionEasierController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Progression - Easier Version",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.arrow_downward),
              ),
              validator: (value) {
                return null; // Optional field
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _progressionHarderController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Progression - Harder Version",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.arrow_upward),
              ),
              validator: (value) {
                return null; // Optional field
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _learningGoalsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Learning Goals",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter learning goals';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Animation Upload Button
            ElevatedButton.icon(
              onPressed: _uploadAnimation,
              icon: const Icon(Icons.movie_creation, size: 18),
              label: const Text("Upload Animation (Optional)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                foregroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            // Show selected file name if one is selected
            if (_selectedAnimationFile != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.file_present, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "File Selected: $_selectedAnimationFile",
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CreateSessionTemplateView extends StatefulWidget {
  const CreateSessionTemplateView({super.key});

  @override
  State<CreateSessionTemplateView> createState() => _CreateSessionTemplateViewState();
}

class _CreateSessionTemplateViewState extends State<CreateSessionTemplateView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _badgeFocusController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  String? _selectedAgeGroup;
  final List<DrillData> _drills = [];
  
  // Age groups for the dropdown
  final List<String> ageGroups = [
    'Little Kicks',
    'Junior Kickers',
    'Mighty Kickers',
    'Mega Kickers'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _badgeFocusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the ViewModel
    final viewModel = Provider.of<AdminViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Session Template", style: TextStyle(color: Colors.white)),
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
              // PDF Upload Button at the top
              PdfAutofillButton(
                onDataExtracted: (Map<String, dynamic> planData) {
                  setState(() {
                    // Map the PDF data to the appropriate controllers
                    if (planData['title'] != null) {
                      _titleController.text = planData['title'].toString();
                    }
                    
                    // Handle age group
                    if (planData['age_group'] != null && planData['age_group'] is String) {
                      String ageGroup = planData['age_group'].toString();
                      if (ageGroups.contains(ageGroup)) {
                        _selectedAgeGroup = ageGroup;
                      }
                    }
                    
                    // Handle badge focus
                    if (planData['badge_focus'] != null) {
                      _badgeFocusController.text = planData['badge_focus'].toString();
                    }
                    
                    // Handle list of drills from AI service
                    if (planData['drills'] != null && planData['drills'] is List) {
                      _drills.clear();
                      List<dynamic> drillsList = planData['drills'] as List;
                      
                      for (var drillJson in drillsList) {
                        if (drillJson is Map<String, dynamic>) {
                          // Handle equipment as List or String
                          String equipment = '';
                          if (drillJson['equipment'] is List) {
                            equipment = (drillJson['equipment'] as List)
                                .map((e) => e.toString())
                                .join(', ');
                          } else if (drillJson['equipment'] != null) {
                            equipment = drillJson['equipment'].toString();
                          }
                          
                          // Handle learning_goals as Object or List
                          String learningGoals = '';
                          if (drillJson['learning_goals'] is Map) {
                            // If it's an object with cognitive, physical, football keys
                            Map<String, dynamic> goals = drillJson['learning_goals'] as Map<String, dynamic>;
                            List<String> goalParts = [];
                            if (goals['cognitive'] != null) goalParts.add('Cognitive: ${goals['cognitive'].toString()}');
                            if (goals['physical'] != null) goalParts.add('Physical: ${goals['physical'].toString()}');
                            if (goals['football'] != null) goalParts.add('Football: ${goals['football'].toString()}');
                            learningGoals = goalParts.join('; ');
                          } else if (drillJson['learning_goals'] is List) {
                            // If it's a list
                            learningGoals = (drillJson['learning_goals'] as List)
                                .map((e) => e.toString())
                                .join(', ');
                          } else if (drillJson['learning_goals'] != null) {
                            // If it's a string
                            learningGoals = drillJson['learning_goals'].toString();
                          }
                          
                          _drills.add(DrillData(
                            title: drillJson['title']?.toString() ?? '',
                            duration: drillJson['duration']?.toString() ?? '',
                            instructions: drillJson['instructions']?.toString() ?? '',
                            equipment: equipment,
                            progressionEasier: drillJson['progression_easier']?.toString() ?? '',
                            progressionHarder: drillJson['progression_harder']?.toString() ?? '',
                            learningGoals: learningGoals,
                          ));
                        }
                      }
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              const Text("Template Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // 1. Title Input
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Template Title",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a template title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. Age Group Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Select Age Group",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                initialValue: _selectedAgeGroup,
                items: ageGroups.map((String group) {
                  return DropdownMenuItem<String>(value: group, child: Text(group));
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedAgeGroup = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an age group';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. Badge Focus Input
              TextFormField(
                controller: _badgeFocusController,
                decoration: const InputDecoration(
                  labelText: "Badge Focus",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.star),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter badge focus';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 4. Drills Section Header
              const Text("Activities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // 5. List of Drills
              if (_drills.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _drills.length,
                  itemBuilder: (context, index) {
                    return DrillFormCard(
                      drill: _drills[index],
                      index: index,
                      onRemove: () {
                        setState(() {
                          _drills.removeAt(index);
                        });
                      },
                    );
                  },
                )
              else
                const Text("No activities added yet. Add an activity using the button below or by uploading a PDF."),
              const SizedBox(height: 16),

              // 6. Add Activity Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _drills.add(DrillData.blank());
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text("Add Activity"),
                ),
              ),
              const SizedBox(height: 32),

              // 7. Save Template Button
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

                        // Validate that at least one drill exists
                        if (_drills.isEmpty) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please add at least one activity."), backgroundColor: Colors.red),
                            );
                          }
                          return;
                        }

                        // Validate that age group is selected
                        if (_selectedAgeGroup == null || _selectedAgeGroup!.isEmpty) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please select an age group."), backgroundColor: Colors.red),
                            );
                          }
                          return;
                        }

                        // Trigger Logic - save the template
                        bool success = await viewModel.createTemplate(
                          title: _titleController.text.trim(),
                          ageGroup: _selectedAgeGroup!,
                          badgeFocus: _badgeFocusController.text.trim(),
                          drills: _drills,
                        );

                        if (success && context.mounted) {
                          Navigator.pop(context); // Go back to dashboard
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Template Saved Successfully!"), backgroundColor: Colors.green),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please fill all fields."), backgroundColor: Colors.red),
                          );
                        }
                      },
                  child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Template", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}