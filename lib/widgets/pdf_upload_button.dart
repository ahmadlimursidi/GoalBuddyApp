import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../services/gemini_pdf_service.dart';
import '../services/storage_service.dart';

class PdfAutofillButton extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataExtracted;

  const PdfAutofillButton({super.key, required this.onDataExtracted});

  @override
  State<PdfAutofillButton> createState() => _PdfAutofillButtonState();
}

class _PdfAutofillButtonState extends State<PdfAutofillButton> {
  bool _isLoading = false;
  final GeminiService _geminiService = GeminiService();
  final StorageService _storageService = StorageService();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // Crucial for getting file bytes
    );

    if (result != null && result.files.first.bytes != null) {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final Uint8List pdfBytes = result.files.first.bytes!;
      final String fileName = result.files.first.name.replaceAll('.pdf', '');

      // Call Gemini 3 to extract data
      String? jsonResponse = await _geminiService.extractLessonPlan(pdfBytes);

      if (!mounted) return;

      if (jsonResponse != null) {
        // Cleanup: Gemini sometimes wraps JSON in ```json ... ```
        String cleanJson = jsonResponse.replaceAll('```json', '').replaceAll('```', '').trim();

        try {
          Map<String, dynamic> data = jsonDecode(cleanJson);

          // Upload PDF to Firebase Storage
          String? pdfUrl = await _storageService.uploadPdfFromBytes(
            pdfBytes: pdfBytes,
            fileName: fileName,
            folder: 'pdfs/session_templates',
          );

          // Add PDF metadata to extracted data
          data['pdfUrl'] = pdfUrl;
          data['pdfFileName'] = result.files.first.name;

          widget.onDataExtracted(data); // Send data to parent form
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✨ Plan Autofilled & PDF Uploaded!")),
            );
          }
        } catch (e) {
          print("JSON Parse Error: $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $e")),
            );
          }
        }
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
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