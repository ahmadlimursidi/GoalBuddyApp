import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class ReceiptData {
  final double? amount;
  final String? date;
  final String? referenceNumber;
  final String? paymentMethod;
  final String? rawText;
  final bool success;
  final String? error;

  ReceiptData({
    this.amount,
    this.date,
    this.referenceNumber,
    this.paymentMethod,
    this.rawText,
    this.success = true,
    this.error,
  });

  factory ReceiptData.error(String message) {
    return ReceiptData(success: false, error: message);
  }
}

class GeminiReceiptService {
  static const String _apiKey = 'AIzaSyCxMNaouejURaEqASAXaJ9r_GO3t9IC1Qs';

  late final GenerativeModel _model;

  GeminiReceiptService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
    );
  }

  /// Extract payment information from a receipt image
  Future<ReceiptData> extractFromImage(Uint8List imageBytes, String mimeType) async {
    try {
      final prompt = TextPart(
        "Analyze this payment receipt image. Extract the following information:\n"
        "1. Total amount paid (in Malaysian Ringgit RM or MYR)\n"
        "2. Payment date\n"
        "3. Reference/Transaction number\n"
        "4. Payment method (e.g., bank transfer, online banking, cash, etc.)\n\n"
        "Return ONLY a JSON object in this exact format (no markdown, no extra text):\n"
        "{\n"
        '  "amount": 150.00,\n'
        '  "date": "2025-01-15",\n'
        '  "reference": "TXN123456789",\n'
        '  "paymentMethod": "Online Banking",\n'
        '  "rawText": "Brief summary of receipt content"\n'
        "}\n\n"
        "Important:\n"
        "- amount should be a number (not string), extract the main payment amount\n"
        "- If you cannot find a value, use null\n"
        "- Focus on finding the payment/transfer amount, not fees or other charges\n"
        "- For Malaysian bank receipts, look for 'Amount', 'Transfer Amount', 'Total', etc."
      );

      final imageData = DataPart(mimeType, imageBytes);
      final content = Content.multi([prompt, imageData]);
      final response = await _model.generateContent([content]);

      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        return ReceiptData.error("No response from AI");
      }

      // Parse the JSON response
      return _parseResponse(responseText);
    } catch (e) {
      print('❌ Gemini Receipt API Error: $e');
      return ReceiptData.error("Failed to analyze receipt: $e");
    }
  }

  /// Extract payment information from a PDF receipt
  Future<ReceiptData> extractFromPdf(Uint8List pdfBytes) async {
    try {
      final prompt = TextPart(
        "Analyze this payment receipt PDF. Extract the following information:\n"
        "1. Total amount paid (in Malaysian Ringgit RM or MYR)\n"
        "2. Payment date\n"
        "3. Reference/Transaction number\n"
        "4. Payment method (e.g., bank transfer, online banking, cash, etc.)\n\n"
        "Return ONLY a JSON object in this exact format (no markdown, no extra text):\n"
        "{\n"
        '  "amount": 150.00,\n'
        '  "date": "2025-01-15",\n'
        '  "reference": "TXN123456789",\n'
        '  "paymentMethod": "Online Banking",\n'
        '  "rawText": "Brief summary of receipt content"\n'
        "}\n\n"
        "Important:\n"
        "- amount should be a number (not string), extract the main payment amount\n"
        "- If you cannot find a value, use null\n"
        "- Focus on finding the payment/transfer amount, not fees or other charges\n"
        "- For Malaysian bank receipts, look for 'Amount', 'Transfer Amount', 'Total', etc."
      );

      final pdfData = DataPart('application/pdf', pdfBytes);
      final content = Content.multi([prompt, pdfData]);
      final response = await _model.generateContent([content]);

      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        return ReceiptData.error("No response from AI");
      }

      return _parseResponse(responseText);
    } catch (e) {
      print('❌ Gemini Receipt PDF API Error: $e');
      return ReceiptData.error("Failed to analyze PDF receipt: $e");
    }
  }

  ReceiptData _parseResponse(String responseText) {
    try {
      // Clean up the response - remove markdown code blocks if present
      String cleanJson = responseText.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      } else if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      // Parse JSON
      final Map<String, dynamic> json = _parseJsonString(cleanJson);

      double? amount;
      if (json['amount'] != null) {
        if (json['amount'] is num) {
          amount = (json['amount'] as num).toDouble();
        } else if (json['amount'] is String) {
          // Try to parse string amount
          final amountStr = (json['amount'] as String)
              .replaceAll('RM', '')
              .replaceAll('MYR', '')
              .replaceAll(',', '')
              .trim();
          amount = double.tryParse(amountStr);
        }
      }

      return ReceiptData(
        amount: amount,
        date: json['date']?.toString(),
        referenceNumber: json['reference']?.toString(),
        paymentMethod: json['paymentMethod']?.toString(),
        rawText: json['rawText']?.toString(),
        success: true,
      );
    } catch (e) {
      print('❌ Error parsing receipt response: $e');
      print('Response was: $responseText');
      return ReceiptData.error("Failed to parse receipt data");
    }
  }

  Map<String, dynamic> _parseJsonString(String jsonString) {
    // Simple JSON parser for the expected format
    final Map<String, dynamic> result = {};

    // Use regex to extract key-value pairs
    final amountMatch = RegExp(r'"amount"\s*:\s*([0-9.]+|null)').firstMatch(jsonString);
    if (amountMatch != null && amountMatch.group(1) != 'null') {
      result['amount'] = double.tryParse(amountMatch.group(1)!);
    }

    final dateMatch = RegExp(r'"date"\s*:\s*"([^"]*)"').firstMatch(jsonString);
    if (dateMatch != null) {
      result['date'] = dateMatch.group(1);
    }

    final refMatch = RegExp(r'"reference"\s*:\s*"([^"]*)"').firstMatch(jsonString);
    if (refMatch != null) {
      result['reference'] = refMatch.group(1);
    }

    final methodMatch = RegExp(r'"paymentMethod"\s*:\s*"([^"]*)"').firstMatch(jsonString);
    if (methodMatch != null) {
      result['paymentMethod'] = methodMatch.group(1);
    }

    final rawMatch = RegExp(r'"rawText"\s*:\s*"([^"]*)"').firstMatch(jsonString);
    if (rawMatch != null) {
      result['rawText'] = rawMatch.group(1);
    }

    return result;
  }
}
