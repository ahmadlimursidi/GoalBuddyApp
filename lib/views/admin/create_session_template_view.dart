import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../view_models/admin_view_model.dart';
import '../../config/theme.dart';
import '../../widgets/pdf_upload_button.dart';
import '../../models/drill_data.dart';

// --- DRILL FORM CARD WIDGET ---
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
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.drill.title);
    
    // Clean duration string to remove "minutes", "mins", etc., leaving only numbers
    String cleanDuration = widget.drill.duration.replaceAll(RegExp(r'[^0-9]'), '');
    _durationController = TextEditingController(text: cleanDuration);
    
    _instructionsController = TextEditingController(text: widget.drill.instructions);
    _equipmentController = TextEditingController(text: widget.drill.equipment);
    _progressionEasierController = TextEditingController(text: widget.drill.progressionEasier);
    _progressionHarderController = TextEditingController(text: widget.drill.progressionHarder);
    _learningGoalsController = TextEditingController(text: widget.drill.learningGoals);

    if (widget.drill.animationUrl != null && widget.drill.animationUrl!.isNotEmpty) {
      _selectedAnimationFile = widget.drill.animationUrl;
    }

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
      setState(() {
        _selectedAnimationFile = result.files.first.name;
        widget.drill.animationUrl = result.files.first.name; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          // Card Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "${widget.index + 1}",
                        style: const TextStyle(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _titleController.text.isNotEmpty ? _titleController.text : "Untitled Activity",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_durationController.text.isNotEmpty)
                          Text(
                            "${_durationController.text} mins",
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: widget.onRemove,
                  ),
                ],
              ),
            ),
          ),
          
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Duration Stacked
                  _buildTextField(
                    controller: _titleController,
                    label: "Activity Title",
                    hint: "E.g. Warm Up Game",
                    icon: Icons.title,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _durationController,
                    label: "Duration (min)",
                    hint: "10",
                    icon: Icons.timer,
                    isNumber: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _instructionsController,
                    label: "Instructions",
                    hint: "Explain how to play...",
                    icon: Icons.description,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _equipmentController,
                    label: "Equipment",
                    hint: "Cones, Balls, Bibs...",
                    icon: Icons.sports_soccer,
                  ),
                  const SizedBox(height: 16),
                  
                  // Progressions Section
                  const Text("Progressions (Optional)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  
                  // Progressions Stacked
                  _buildTextField(
                    controller: _progressionEasierController,
                    label: "Easier Variation",
                    hint: "Make it simple...",
                    icon: Icons.arrow_downward,
                    maxLines: 2,
                    isOptional: true,
                    accentColor: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _progressionHarderController,
                    label: "Harder Variation",
                    hint: "Add a challenge...",
                    icon: Icons.arrow_upward,
                    maxLines: 2,
                    isOptional: true,
                    accentColor: Colors.red,
                  ),
                  
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _learningGoalsController,
                    label: "Learning Goals",
                    hint: "Cognitive, Physical, Football skills...",
                    icon: Icons.school,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  // Animation Upload
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.movie_filter, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Tactical Animation",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                              ),
                              Text(
                                _selectedAnimationFile ?? "Upload .json Lottie file",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _selectedAnimationFile != null ? Colors.green : Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _uploadAnimation,
                          child: const Text("Browse"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    bool isNumber = false,
    bool isOptional = false,
    Color? accentColor,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        labelStyle: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor ?? AppTheme.primaryRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: Icon(icon, color: accentColor ?? Colors.grey[500], size: 20),
        alignLabelWithHint: maxLines > 1,
      ),
      validator: (value) {
        if (isOptional) return null;
        if (value == null || value.isEmpty) return 'Required';
        if (isNumber && int.tryParse(value) == null) return 'Invalid #';
        return null;
      },
    );
  }
}

// --- CREATE TEMPLATE VIEW ---
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
  String? _pdfUrl;          // Store the PDF URL from Firebase Storage
  String? _pdfFileName;     // Store the original PDF filename

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
    final viewModel = Provider.of<AdminViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: const Text("New Template"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Header with AI Action
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
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
            child: Column(
              children: [
                const Text(
                  "Create Curriculum",
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Session Template",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                // AI Autofill Card
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                            SizedBox(width: 8),
                            Text("Fast Track with AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      // Pass the callback to the existing widget
                      PdfAutofillButton(
                        onDataExtracted: (Map<String, dynamic> planData) {
                          setState(() {
                            if (planData['title'] != null) _titleController.text = planData['title'].toString();
                            if (planData['age_group'] != null) {
                              String ag = planData['age_group'].toString();
                              if (ageGroups.contains(ag)) _selectedAgeGroup = ag;
                            }
                            if (planData['badge_focus'] != null) _badgeFocusController.text = planData['badge_focus'].toString();

                            // Capture PDF metadata
                            if (planData['pdfUrl'] != null) _pdfUrl = planData['pdfUrl'].toString();
                            if (planData['pdfFileName'] != null) _pdfFileName = planData['pdfFileName'].toString();

                            if (planData['drills'] != null && planData['drills'] is List) {
                              _drills.clear();
                              for (var d in planData['drills']) {
                                _drills.add(DrillData(
                                  title: d['title'] ?? '',
                                  duration: d['duration']?.toString() ?? '5',
                                  instructions: d['instructions'] ?? '',
                                  equipment: d['equipment'] is List ? (d['equipment'] as List).join(', ') : d['equipment']?.toString() ?? '',
                                  progressionEasier: d['progression_easier'] ?? '',
                                  progressionHarder: d['progression_harder'] ?? '',
                                  learningGoals: d['learning_goals'] is List ? (d['learning_goals'] as List).join(', ') : d['learning_goals']?.toString() ?? '',
                                ));
                              }
                            }
                          });
                        },
                      ),
                    ],
                  ),
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
                    // Metadata Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("General Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                          const SizedBox(height: 16),
                          _buildTextField(_titleController, "Template Title", Icons.title),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedAgeGroup,
                            decoration: _inputDecoration("Age Group", Icons.group),
                            items: ageGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (v) => setState(() => _selectedAgeGroup = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(_badgeFocusController, "Badge Focus", Icons.star),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Drills Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text("Activities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                              child: Text("${_drills.length}", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _drills.add(DrillData.blank())),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryRed,
                            side: const BorderSide(color: AppTheme.primaryRed),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Add Drill"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_drills.isEmpty)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!, width: 2, style: BorderStyle.solid),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.sports_soccer, size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text("No activities yet", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("Use AI Autofill above or add manually", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _drills.length,
                        itemBuilder: (context, index) {
                          return DrillFormCard(
                            drill: _drills[index],
                            index: index,
                            onRemove: () => setState(() => _drills.removeAt(index)),
                          );
                        },
                      ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : () async {
                          if (!_formKey.currentState!.validate()) return;
                          if (_drills.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Add at least one activity"), backgroundColor: Colors.red));
                            return;
                          }
                          
                          bool success = await viewModel.createTemplate(
                            title: _titleController.text.trim(),
                            ageGroup: _selectedAgeGroup!,
                            badgeFocus: _badgeFocusController.text.trim(),
                            drills: _drills,
                            pdfUrl: _pdfUrl,
                            pdfFileName: _pdfFileName,
                          );

                          if (success && context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Template Saved!"), backgroundColor: Colors.green));
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
                            : const Text("Save Template", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, icon),
      validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryRed)),
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}