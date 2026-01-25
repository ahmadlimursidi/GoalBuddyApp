import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../services/storage_service.dart';
import '../../services/gemini_receipt_service.dart';

class PaymentDetailsView extends StatefulWidget {
  final String monthYear;
  final String studentId;
  final String studentName;

  const PaymentDetailsView({
    super.key,
    required this.monthYear,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<PaymentDetailsView> createState() => _PaymentDetailsViewState();
}

class _PaymentDetailsViewState extends State<PaymentDetailsView> {
  // Bank Details - You can update these with real values
  static const String bankName = "Maybank";
  static const String accountName = "Little Kickers Cyberjaya";
  static const String accountNumber = "5621 8765 4321";
  static const double monthlyFee = 150.00; // RM

  // Receipt upload state
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  String? _selectedFileType;
  bool _isUploading = false;
  bool _isAnalyzing = false;
  final StorageService _storageService = StorageService();
  final GeminiReceiptService _receiptService = GeminiReceiptService();

  // AI-extracted data
  final TextEditingController _amountController = TextEditingController();
  String? _extractedDate;
  String? _extractedReference;
  String? _extractedPaymentMethod;
  bool _hasAnalyzed = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: AppTheme.pitchGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final contentType = _getContentType(file.extension ?? '');
          setState(() {
            _selectedFileBytes = file.bytes;
            _selectedFileName = file.name;
            _selectedFileType = contentType;
            _hasAnalyzed = false;
            _errorMessage = null;
          });

          // Auto-analyze receipt with AI
          await _analyzeReceipt(file.bytes!, contentType);
        }
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error selecting file: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _analyzeReceipt(Uint8List bytes, String mimeType) async {
    if (!mounted) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      ReceiptData result;
      if (mimeType == 'application/pdf') {
        result = await _receiptService.extractFromPdf(bytes);
      } else {
        result = await _receiptService.extractFromImage(bytes, mimeType);
      }

      if (!mounted) return;

      if (result.success) {
        setState(() {
          if (result.amount != null) {
            _amountController.text = result.amount!.toStringAsFixed(2);
          }
          _extractedDate = result.date;
          _extractedReference = result.referenceNumber;
          _extractedPaymentMethod = result.paymentMethod;
          _hasAnalyzed = true;
          _isAnalyzing = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _selectedFileBytes = null;
          _selectedFileName = null;
          _selectedFileType = null;
          _hasAnalyzed = false;
          _isAnalyzing = false;
          _errorMessage = result.error ?? 'Invalid file. Please upload a valid payment receipt.';
        });
      }
    } catch (e) {
      debugPrint("Error analyzing receipt: $e");
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _hasAnalyzed = false;
          _selectedFileBytes = null;
          _selectedFileName = null;
          _selectedFileType = null;
          _errorMessage = "Error analyzing file. Please try again.";
        });
      }
    }
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _submitPayment() async {
    if (_selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload a receipt or screenshot as proof of payment"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload receipt to Firebase Storage
      final receiptUrl = await _storageService.uploadPaymentReceipt(
        fileBytes: _selectedFileBytes!,
        studentId: widget.studentId,
        monthYear: widget.monthYear,
        fileName: _selectedFileName ?? 'receipt',
        contentType: _selectedFileType ?? 'application/octet-stream',
      );

      if (receiptUrl == null) {
        throw Exception("Failed to upload receipt");
      }

      // Parse amount from controller
      final amount = double.tryParse(_amountController.text) ?? 0;

      // Save payment record to Firestore
      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .collection('payments')
          .doc(widget.monthYear.replaceAll(' ', '_'))
          .set({
        'month': widget.monthYear,
        'amount': amount,
        'status': 'pending',
        'parentConfirmed': true,
        'adminConfirmed': false,
        'parentConfirmedAt': FieldValue.serverTimestamp(),
        'adminConfirmedAt': null,
        'notes': 'Parent confirmed payment for ${widget.monthYear}',
        'studentId': widget.studentId,
        'studentName': widget.studentName,
        'receiptUrl': receiptUrl,
        'receiptFileName': _selectedFileName,
        'receiptType': _selectedFileType,
        // AI-extracted data for admin reference
        'aiExtractedAmount': amount,
        'aiExtractedDate': _extractedDate,
        'aiExtractedReference': _extractedReference,
        'aiExtractedPaymentMethod': _extractedPaymentMethod,
      });

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment confirmation sent to admin for approval"),
            backgroundColor: AppTheme.pitchGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error submitting payment: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error confirming payment: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryRed, Color(0xFFC41A1F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.payment, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    "Payment for ${widget.monthYear}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "RM ${monthlyFee.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // QR Code Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        const Text(
                          "Scan to Pay",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // QR Code Placeholder - Replace with actual QR image
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_2, size: 100, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                "QR Code Placeholder",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // TODO: Replace above Container with actual QR image:
                        // Image.asset(
                        //   'assets/images/payment_qr.png',
                        //   width: 200,
                        //   height: 200,
                        //   fit: BoxFit.contain,
                        // ),
                        const SizedBox(height: 16),
                        Text(
                          "Scan this QR code with your banking app",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Divider with "OR"
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Bank Transfer Details
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.account_balance, color: AppTheme.primaryRed),
                            SizedBox(width: 12),
                            Text(
                              "Bank Transfer Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Bank Name
                        _buildBankDetailRow(
                          label: "Bank Name",
                          value: bankName,
                          icon: Icons.business,
                          onCopy: () => _copyToClipboard(bankName, "Bank name"),
                        ),
                        const Divider(height: 24),

                        // Account Name
                        _buildBankDetailRow(
                          label: "Account Name",
                          value: accountName,
                          icon: Icons.person,
                          onCopy: () => _copyToClipboard(accountName, "Account name"),
                        ),
                        const Divider(height: 24),

                        // Account Number
                        _buildBankDetailRow(
                          label: "Account Number",
                          value: accountNumber,
                          icon: Icons.numbers,
                          onCopy: () => _copyToClipboard(accountNumber.replaceAll(' ', ''), "Account number"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Upload Receipt Section
                  const Text(
                    "Upload Payment Proof",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "After making the payment, upload a screenshot or receipt as proof",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // File Upload Area
                  InkWell(
                    onTap: _isUploading ? null : _pickFile,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _selectedFileBytes != null
                            ? AppTheme.pitchGreen.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedFileBytes != null
                              ? AppTheme.pitchGreen
                              : Colors.grey[300]!,
                          width: 2,
                          style: _selectedFileBytes != null
                              ? BorderStyle.solid
                              : BorderStyle.solid,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedFileBytes != null
                                ? Icons.check_circle
                                : Icons.cloud_upload_outlined,
                            size: 48,
                            color: _selectedFileBytes != null
                                ? AppTheme.pitchGreen
                                : Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedFileName ?? "Tap to upload receipt",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedFileBytes != null
                                  ? AppTheme.pitchGreen
                                  : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_selectedFileBytes == null) ...[
                            const SizedBox(height: 4),
                            Text(
                              "PDF, PNG, JPG, JPEG",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Image Preview
                  if (_selectedFileBytes != null &&
                      (_selectedFileType?.startsWith('image/') ?? false)) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _selectedFileBytes!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],

                  // AI Analysis Loading
                  if (_selectedFileBytes != null && _isAnalyzing) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "AI is reading your receipt...",
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // AI Extracted Data
                  if (_selectedFileBytes != null && _hasAnalyzed) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.pitchGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.pitchGreen.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 16, color: AppTheme.pitchGreen),
                              const SizedBox(width: 6),
                              Text(
                                "AI-Detected Payment Details",
                                style: TextStyle(
                                  color: AppTheme.pitchGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: "Payment Amount (RM)",
                              hintText: "Enter amount",
                              prefixText: "RM ",
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppTheme.pitchGreen),
                              ),
                            ),
                          ),
                          if (_extractedReference != null || _extractedPaymentMethod != null) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                if (_extractedPaymentMethod != null)
                                  _buildInfoChip(Icons.payment, _extractedPaymentMethod!),
                                if (_extractedReference != null)
                                  _buildInfoChip(Icons.tag, _extractedReference!),
                                if (_extractedDate != null)
                                  _buildInfoChip(Icons.calendar_today, _extractedDate!),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            "You can edit the amount if it's incorrect",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Change File Button
                  if (_selectedFileBytes != null) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        onPressed: (_isUploading || _isAnalyzing) ? null : _pickFile,
                        icon: const Icon(Icons.swap_horiz, size: 18),
                        label: const Text("Change file"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_isUploading || _isAnalyzing) ? null : _submitPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "Submit Payment",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailRow({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onCopy,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryRed, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkText,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onCopy,
          icon: const Icon(Icons.copy, size: 20),
          color: Colors.grey[500],
          tooltip: "Copy",
        ),
      ],
    );
  }
}
