import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/i18n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/language_selector_sheet.dart';
import 'business_profile_form_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool startInCreateAccountTab;
  const AuthScreen({Key? key, this.startInCreateAccountTab = false}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLoginTab;

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoginTab = !widget.startInCreateAccountTab;
  }

  void _submit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (_isLoginTab) {
      if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your registered email address and password.")),
        );
        return;
      }

      setState(() => _isLoading = true);
      bool success = await auth.login(_emailController.text.trim(), _passwordController.text.trim());
      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BusinessProfileFormScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Authentication failed. Invalid email address or password."),
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
        _showEmailOTPDialog(
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
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

  void _showEmailOTPDialog({
    required String phone,
    required String email,
  }) {
    final otpController = TextEditingController();
    bool isVerifying = false;
    bool isResending = false;
    int secondsRemaining = 15;
    Timer? countdownTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
              if (secondsRemaining > 0) {
                setModalState(() => secondsRemaining--);
              } else {
                timer.cancel();
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.mark_email_read_rounded, color: AppTheme.primaryBlue, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr("otp_title"),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr("otp_subtitle"),
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        email,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: "• • • • • •",
                        hintStyle: const TextStyle(letterSpacing: 4),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        counterText: "",
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: secondsRemaining == 0 && !isResending
                              ? () async {
                                  setModalState(() => isResending = true);
                                  final auth = Provider.of<AuthProvider>(context, listen: false);
                                  final res = await auth.resendOtp(phone, email: email);
                                  setModalState(() {
                                    isResending = false;
                                    secondsRemaining = 15;
                                  });

                                  countdownTimer?.cancel();
                                  countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                                    if (secondsRemaining > 0) {
                                      setModalState(() => secondsRemaining--);
                                    } else {
                                      timer.cancel();
                                    }
                                  });

                                  if (res["success"] == true && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("📩 Fresh 6-digit OTP dispatched to $email!"),
                                        backgroundColor: AppTheme.primaryBlue,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          icon: isResending
                              ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                              : Icon(
                                  Icons.replay_rounded,
                                  size: 16,
                                  color: secondsRemaining == 0 ? AppTheme.primaryBlue : Colors.grey,
                                ),
                          label: Text(
                            secondsRemaining > 0
                                ? context.tr("resend_in", {"seconds": "$secondsRemaining"})
                                : context.tr("resend_otp"),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: secondsRemaining == 0 ? AppTheme.primaryBlue : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    countdownTimer?.cancel();
                    Navigator.pop(ctx);
                  },
                  child: Text(context.tr("cancel")),
                ),
                ElevatedButton(
                  onPressed: isVerifying
                      ? null
                      : () async {
                          final cleanEnteredOtp = otpController.text.replaceAll(" ", "").trim();
                          if (cleanEnteredOtp.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter the complete 6-digit OTP code."),
                                backgroundColor: AppTheme.warningOrange,
                              ),
                            );
                            return;
                          }

                          setModalState(() => isVerifying = true);
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          final bool success = await auth.verifyOtp(phone, cleanEnteredOtp);
                          setModalState(() => isVerifying = false);

                          if (success && mounted) {
                            countdownTimer?.cancel();
                            Navigator.pop(ctx);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Account verified successfully! You can now log in."),
                                backgroundColor: AppTheme.successGreen,
                              ),
                            );

                            setState(() {
                              _isLoginTab = true;
                              _emailController.text = email;
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
                      : Text(context.tr("verify_otp_btn")),
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
    final localeProv = Provider.of<LocaleProvider>(context);
    final currentLang = localeProv.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginTab ? context.tr("login_title") : context.tr("create_account_title")),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            tooltip: context.tr("change_language"),
            onPressed: () => LanguageSelectorSheet.show(context),
          ),
        ],
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
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(context.tr("tab_login"), style: const TextStyle(fontSize: 16)),
                  ),
                  selected: _isLoginTab,
                  onSelected: (val) => setState(() => _isLoginTab = true),
                ),
                const SizedBox(width: 20),
                ChoiceChip(
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(context.tr("tab_create_account"), style: const TextStyle(fontSize: 16)),
                  ),
                  selected: !_isLoginTab,
                  onSelected: (val) => setState(() => _isLoginTab = false),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_isLoginTab) ...[
              // Registered Email Address for Login
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: context.tr("registered_email"),
                  hintText: context.tr("email_hint"),
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Full Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.tr("full_name"),
                  hintText: context.tr("full_name_hint"),
                  prefixIcon: const Icon(Icons.person_outline),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Email Address
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: context.tr("registered_email"),
                  hintText: context.tr("email_hint"),
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: context.tr("phone_number"),
                  hintText: context.tr("phone_hint"),
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: context.tr("password"),
                hintText: _isLoginTab ? context.tr("password_hint") : context.tr("password_min_hint"),
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
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
                        _isLoginTab ? context.tr("btn_login_submit") : context.tr("btn_register_submit"),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            if (_isLoginTab)
              TextButton(
                onPressed: () {
                  _emailController.text = "ramesh@example.com";
                  _passwordController.text = "123456";
                  _submit();
                },
                child: Text(context.tr("btn_demo_login")),
              )
          ],
        ),
      ),
    );
  }
}
