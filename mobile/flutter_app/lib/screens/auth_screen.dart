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
      // Account Creation Flow
      if (_nameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _phoneController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all required fields to create your account.")),
        );
        return;
      }

      setState(() => _isLoading = true);

      final res = await auth.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        aadhaarNumber: "",
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (res["success"] == true && mounted) {
        final devOtp = res["data"]?["dev_otp"]?.toString();
        _showEmailOTPDialog(
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          devOtp: devOtp,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res["error"]?["message"] ?? "Account creation failed. Phone or Email already registered."),
            backgroundColor: AppTheme.warningOrange,
          ),
        );
      }
    }
  }

  void _showEmailOTPDialog({required String phone, required String email, String? devOtp}) {
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
                  Icon(Icons.mark_email_read_rounded, color: AppTheme.primaryBlue, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Email OTP Verification",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "A 6-digit verification code has been sent to your registered email address:",
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 18, color: AppTheme.primaryBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            email,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(letterSpacing: 8, fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: "• • • • • •",
                      labelText: "Enter 6-Digit OTP",
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "ℹ Please check your inbox or spam folder for the email from SchemeMate AI.",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
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
                          final cleanEnteredOtp = otpController.text.replaceAll(" ", "").trim();
                          if (cleanEnteredOtp.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter the full 6-digit OTP code."),
                                backgroundColor: AppTheme.warningOrange,
                              ),
                            );
                            return;
                          }

                          setModalState(() => isVerifying = true);
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          bool verified = await auth.verifyOtp(phone, cleanEnteredOtp);
                          setModalState(() => isVerifying = false);

                          if (verified && mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("✅ Account created and email verified! Please login."),
                                backgroundColor: AppTheme.successGreen,
                              ),
                            );

                            // Redirect to Login Tab with phone pre-filled
                            setState(() {
                              _isLoginTab = true;
                              _phoneController.text = phone;
                              _passwordController.clear();
                            });
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invalid OTP code. Please check the code sent to your email."),
                                backgroundColor: AppTheme.warningOrange,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Verify OTP & Activate Account"),
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
      appBar: AppBar(
        title: Text(_isLoginTab ? "Login to SchemeMate AI" : "Create New Account"),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text("Login", style: TextStyle(fontSize: 16)),
                  ),
                  selected: _isLoginTab,
                  onSelected: (val) => setState(() => _isLoginTab = true),
                ),
                const SizedBox(width: 20),
                ChoiceChip(
                  label: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text("Create Account", style: TextStyle(fontSize: 16)),
                  ),
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
                  hintText: "e.g. Ramesh Kumar",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Email Address
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  hintText: "e.g. elangoai12@gmail.com",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
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
                hintText: "10-digit mobile number",
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
                hintText: "At least 6 characters",
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
                        _isLoginTab ? "Login" : "Create Account & Send Email OTP",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            if (_isLoginTab)
              TextButton(
                onPressed: () {
                  // Demo quick login
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
