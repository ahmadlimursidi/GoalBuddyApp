import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../../services/firestore_service.dart';
import '../../config/theme.dart';

class AdminCoachesView extends StatefulWidget {
  const AdminCoachesView({super.key});

  @override
  State<AdminCoachesView> createState() => _AdminCoachesViewState();
}

class _AdminCoachesViewState extends State<AdminCoachesView> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rateController = TextEditingController();

  // State
  bool _isLoading = false;
  bool _showAddForm = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _registerCoach() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await _firestoreService.registerCoach(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        ratePerHour: double.parse(_rateController.text.trim()),
      );

      if (success && mounted) {
        _showSuccessSnackBar('Coach registered successfully!');
        _clearForm();
      } else if (mounted) {
        _showErrorSnackBar('Error registering coach. Please check details.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _rateController.clear();
    setState(() {
      _showAddForm = false;
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _generateRandomPassword() {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%&*';
    final Random random = Random();
    String password = '';

    password += 'abcdefghijklmnopqrstuvwxyz'[random.nextInt(26)];
    password += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[random.nextInt(26)];
    password += '0123456789'[random.nextInt(10)];
    password += '!@#\$%&*'[random.nextInt(7)];

    int length = 8 + random.nextInt(5);
    for (int i = password.length; i < length; i++) {
      password += chars[random.nextInt(chars.length)];
    }

    List<String> passwordList = password.split('');
    passwordList.shuffle();
    return passwordList.join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: const Text("Manage Coaches"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _showAddForm = !_showAddForm;
          });
        },
        backgroundColor: AppTheme.primaryRed,
        icon: Icon(_showAddForm ? Icons.close : Icons.add, color: Colors.white),
        label: Text(
          _showAddForm ? "Cancel" : "Add Coach",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
                  "Team Overview",
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text(
                  "All Coaches",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // 2. Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Section
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: _buildAddCoachForm(),
                    crossFadeState: _showAddForm ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),

                  if (_showAddForm) const SizedBox(height: 24),

                  // List Header
                  const Text(
                    "Registered Staff",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                  ),
                  const SizedBox(height: 16),

                  // Coaches List
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService.getCoaches(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyState();
                      }

                      // Sort coaches by name
                      var coaches = List.from(snapshot.data!.docs);
                      coaches.sort((a, b) {
                        var aName = (a.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? '';
                        var bName = (b.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? '';
                        return aName.compareTo(bName);
                      });

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: coaches.length,
                        itemBuilder: (context, index) {
                          var coachDoc = coaches[index];
                          var coachData = coachDoc.data() as Map<String, dynamic>;
                          return _buildCoachCard(coachData);
                        },
                      );
                    },
                  ),
                  
                  // Bottom padding for FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCoachForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Add New Coach", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => setState(() => _showAddForm = false),
                )
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            _buildTextField(controller: _nameController, label: 'Full Name', icon: Icons.person),
            const SizedBox(height: 16),
            _buildTextField(controller: _emailController, label: 'Email Address', icon: Icons.email, isEmail: true),
            const SizedBox(height: 16),
            _buildTextField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone, isPhone: true),
            const SizedBox(height: 16),
            
            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                    IconButton(
                      icon: const Icon(Icons.autorenew, color: AppTheme.primaryRed),
                      tooltip: "Generate Random Password",
                      onPressed: () {
                        setState(() {
                          _passwordController.text = _generateRandomPassword();
                          _passwordVisible = true; // Show generated password
                        });
                      },
                    ),
                  ],
                ),
              ),
              validator: (val) => (val == null || val.length < 6) ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 16),
            
            _buildTextField(controller: _rateController, label: 'Rate per Hour (RM)', icon: Icons.attach_money, isNumber: true),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerCoach,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? Lottie.network(
                        'https://lottie.host/6807242f-8d6a-4102-a3f0-9a01fa8b3ef2/3SY7jwapQ2.json',
                        width: 40, height: 40)
                    : const Text("Save Coach", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isEmail = false,
    bool isPhone = false,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : (isPhone ? TextInputType.phone : (isEmail ? TextInputType.emailAddress : TextInputType.text)),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        prefixIcon: Icon(icon, color: Colors.grey),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (isEmail && !value.contains('@')) return 'Invalid Email';
        if (isPhone && value.length < 9) return 'Invalid Phone';
        return null;
      },
    );
  }

  Widget _buildCoachCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  data['name'] != null && data['name'].isNotEmpty ? data['name'][0].toUpperCase() : 'C',
                  style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'Unknown',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          data['email'] ?? 'No email',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'RM ${data['ratePerHour']?.toStringAsFixed(0) ?? '0'}/hr',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'edit') {
                  _editCoach(data);
                } else if (value == 'delete') {
                  _deleteCoach(data);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, color: AppTheme.primaryRed, size: 20),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.people_outline, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No coaches found",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _editCoach(Map<String, dynamic> coachData) {
    String? coachEmail = coachData['email'] as String?;
    if (coachEmail == null) {
      _showErrorSnackBar('Unable to edit coach');
      return;
    }

    // Pre-fill form with existing data
    _nameController.text = coachData['name'] ?? '';
    _emailController.text = coachEmail;
    _phoneController.text = coachData['phone'] ?? '';
    _rateController.text = coachData['ratePerHour']?.toString() ?? '';

    // Show edit dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit, color: AppTheme.primaryRed),
            SizedBox(width: 12),
            Text('Edit Coach'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(controller: _nameController, label: 'Full Name', icon: Icons.person),
              const SizedBox(height: 12),
              _buildTextField(controller: _emailController, label: 'Email Address', icon: Icons.email, isEmail: true),
              const SizedBox(height: 12),
              _buildTextField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone, isPhone: true),
              const SizedBox(height: 12),
              _buildTextField(controller: _rateController, label: 'Rate per Hour (RM)', icon: Icons.attach_money, isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.trim().isEmpty) {
                _showErrorSnackBar('Name is required');
                return;
              }

              try {
                await FirebaseFirestore.instance.collection('coaches').doc(coachEmail).update({
                  'name': _nameController.text.trim(),
                  'phone': _phoneController.text.trim(),
                  'ratePerHour': double.tryParse(_rateController.text.trim()) ?? 0.0,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                if (mounted) {
                  Navigator.pop(context);
                  _showSuccessSnackBar('Coach updated successfully!');
                  _clearForm();
                }
              } catch (e) {
                _showErrorSnackBar('Error updating coach: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteCoach(Map<String, dynamic> coachData) {
    String? coachEmail = coachData['email'] as String?;
    String coachName = coachData['name'] ?? 'this coach';

    if (coachEmail == null) {
      _showErrorSnackBar('Unable to delete coach');
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Coach'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete $coachName?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will permanently remove the coach and their account.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Delete coach document
                await FirebaseFirestore.instance.collection('coaches').doc(coachEmail).delete();

                if (mounted) {
                  Navigator.pop(context);
                  _showSuccessSnackBar('Coach deleted successfully');
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  _showErrorSnackBar('Error deleting coach: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}