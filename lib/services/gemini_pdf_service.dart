import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // ⚠️ Replace with your actual key from aistudio.google.com
  static const String _apiKey = 'AIzaSyCxMNaouejURaEqASAXaJ9r_GO3t9IC1Qs';

  late final GenerativeModel _model;

  GeminiService() {
    // Using Gemini 3 Flash Preview model
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: _apiKey,
    );
  }

  Future<String?> extractLessonPlan(Uint8List pdfBytes) async {
    print('🔵 [GeminiService] Starting PDF extraction...');
    print('🔵 [GeminiService] PDF size: ${pdfBytes.length} bytes');

    try {
      final prompt = TextPart(
          "Analyze this PDF. First, determine if it is a Little Kickers football lesson plan document. "
          "A valid Little Kickers lesson plan should contain: "
          "- Age group references like 'Little Kickers', 'Junior Kickers', 'Mighty Kickers', or 'Mega Kickers' "
          "- Structured drills/activities such as Warm Up, Main Game, Penalty, Match, or similar training exercises "
          "- Badge focus or learning objectives "
          "- Week number or session title "
          "If the PDF is NOT a Little Kickers lesson plan (e.g., it's a receipt, invoice, random document, or a different football program), "
          "return ONLY this JSON: {\"error\": \"INVALID_DOCUMENT\", \"message\": \"This PDF is not a valid Little Kickers lesson plan. Please upload an official Little Kickers lesson plan template.\"} "
          "If it IS a valid Little Kickers lesson plan, extract the data into a structured JSON object. "
          "Return clean JSON ONLY (no markdown formatting). Structure:"
          "{"
          "  'title': 'String (e.g. Junior Kickers Week 5)',"
          "  'duration_minutes': int,"
          "  'badge_focus': 'String',"
          "  'age_group': 'String',"
          "  'drills': ["
          "    {"
          "      'title': 'String (e.g. Warm Up Game - Farmer Relay)',"
          "      'duration_min': int (estimate if not explicit),"
          "      'instructions': 'String',"
          "      'equipment': ['String'],"
          "      'progression_easier': 'String',"
          "      'progression_harder': 'String',"
          "      'learning_goals': ['String']"
          "    }"
          "  ]"
          "}"
      );

      print('🔵 [GeminiService] Prompt created, sending to Gemini...');

      final pdfData = DataPart('application/pdf', pdfBytes);
      final content = Content.multi([prompt, pdfData]);

      print('🔵 [GeminiService] Calling generateContent...');
      final response = await _model.generateContent([content]);

      print('🔵 [GeminiService] Response received');
      print('🔵 [GeminiService] Response text: ${response.text}');

      return response.text;
    } catch (e, stackTrace) {
      print('❌ [GeminiService] Gemini API Error: $e');
      print('❌ [GeminiService] Stack trace: $stackTrace');
      return null;
    }
  }
}