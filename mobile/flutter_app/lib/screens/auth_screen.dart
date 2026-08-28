import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'business_profile_form_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginTab = true;

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _aadhaarController = TextEditingController();

  bool _isLoading = false;

  void _submit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (_isLoginTab) {
      if (_phoneController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter phone number and password.")),
        );
        return;
      }

      setState(() => _isLoading = true);
      bool success = await auth.login(_phoneController.text.trim(), _passwordController.text.trim());
      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BusinessProfileFormScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Authentication failed. Invalid phone number or password."),
            backgroundColor: AppTheme.warningOrange,
          ),
        );
      }
    } else {
      // Registration Flow
      if (_nameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _aadhaarController.text.trim().isEmpty ||
          _phoneController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all required registration fields.")),
        );
        return;
      }

      setState(() => _isLoading = true);

      final res = await auth.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        aadhaarNumber: _aadhaarController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (res["success"] == true && mounted) {
        _showEmailOTPDialog(
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res["error"]?["message"] ?? "Registration failed. Phone or Email already registered."),
            backgroundColor: AppTheme.warningOrange,
          ),
        );
      }
    }
  }

  void _showEmailOTPDialog({required String phone, required String email}) {
    final otpController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.mark_email_read_rounded, color: AppTheme.primaryBlue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Security Email OTP Verification",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "For enhanced security, a 6-digit verification OTP has been sent to your registered email address:\n",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email, size: 16, color: AppTheme.primaryBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            email,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: "Enter 6-Digit Security OTP",
                      prefixIcon: Icon(Icons.security),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isVerifying
                      ? null
                      : () async {
                          setModalState(() => isVerifying = true);
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          bool verified = await auth.verifyOtp(phone, otpController.text.trim());
                          setModalState(() => isVerifying = false);

                          if (verified && mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("✅ Account created & Email verified! Redirecting to Login..."),
                                backgroundColor: AppTheme.successGreen,
                              ),
                            );

                            // Switch to Login Tab with phone pre-filled
                            setState(() {
                              _isLoginTab = true;
                              _phoneController.text = phone;
                            });
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invalid OTP code. Please enter valid 6-digit OTP."),
                                backgroundColor: AppTheme.warningOrange,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
                  child: isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Verify OTP & Complete Registration"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLoginTab ? "Login" : "Register New Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Login", style: TextStyle(fontSize: 16)),
                  selected: _isLoginTab,
                  onSelected: (val) => setState(() => _isLoginTab = true),
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text("Register", style: TextStyle(fontSize: 16)),
                  selected: !_isLoginTab,
                  onSelected: (val) => setState(() => _isLoginTab = false),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (!_isLoginTab) ...[
              // Full Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Email ID
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  hintText: "example@gmail.com",
                ),
              ),
              const SizedBox(height: 16),

              // Aadhaar Number
              TextField(
                controller: _aadhaarController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Aadhaar Number (12 Digits)",
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                  hintText: "1234 5678 9012",
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Phone Number
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryBlue,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isLoginTab ? "Login" : "Send Email OTP & Register",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            if (_isLoginTab)
              TextButton(
                onPressed: () {
                  // Demo bypass for quick presentation
                  _phoneController.text = "9876543210";
                  _passwordController.text = "123456";
                  _submit();
                },
                child: const Text("Demo One-Click Login (9876543210)"),
              )
          ],
        ),
      ),
    );
  }
}
