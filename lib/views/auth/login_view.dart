import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../view_models/auth_view_model.dart';
import '../../config/theme.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Lottie.asset(
                'assets/animations/login_animation.json',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                "GOALBUDDY",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.primaryRed,
                ),
              ),
              Text(
                "by Little Kickers Cyber-Putra",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 48),

              if (authViewModel.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authViewModel.errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: authViewModel.isLoading 
                  ? null 
                  : () async {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();

                      // 1. Attempt Login
                      // We expect authViewModel.login to return the role string (e.g. "admin", "coach")
                      // or null if failed.
                      var result = await authViewModel.login(email, password);
                      
                      if (result != null && context.mounted) {
                        String role = result.toString(); // Ensure it's a string
                        
                        // 2. Role Based Redirection Logic
                        if (role == "admin") {
                           Navigator.pushReplacementNamed(context, '/admin_dashboard');
                        } else if (role == "student_parent") {
                           Navigator.pushReplacementNamed(context, '/student_parent_dashboard');
                        } else {
                           Navigator.pushReplacementNamed(context, '/dashboard');
                        }
                      }
                    },
                child: authViewModel.isLoading
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text("Sign In", style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Try admin@littlekickers.com, coach@littlekickers.com, or parent@example.com"))
                   );
                },
                child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}