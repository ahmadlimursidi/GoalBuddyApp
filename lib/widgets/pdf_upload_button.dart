import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../services/gemini_pdf_service.dart';

class PdfAutofillButton extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataExtracted;

  const PdfAutofillButton({super.key, required this.onDataExtracted});

  @override
  State<PdfAutofillButton> createState() => _PdfAutofillButtonState();
}

class _PdfAutofillButtonState extends State<PdfAutofillButton> {
  bool _isLoading = false;
  final GeminiService _geminiService = GeminiService();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // Crucial for getting file bytes
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() => _isLoading = true);
      
      // Call Gemini 3
      String? jsonResponse = await _geminiService.extractLessonPlan(result.files.first.bytes!);

      if (jsonResponse != null) {
        // Cleanup: Gemini sometimes wraps JSON in ```json ... ```
        String cleanJson = jsonResponse.replaceAll('```json', '').replaceAll('```', '').trim();
        
        try {
          Map<String, dynamic> data = jsonDecode(cleanJson);
          widget.onDataExtracted(data); // Send data to parent form
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✨ Plan Autofilled!")));
        } catch (e) {
          print("JSON Parse Error: $e");
        }
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _pickFile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
            : const Icon(Icons.picture_as_pdf),
        label: Text(_isLoading ? "Gemini 3 is reading..." : "Autofill from PDF"),
      ),
    );
  }
}