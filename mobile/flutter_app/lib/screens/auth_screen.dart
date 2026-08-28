import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'business_profile_form_screen.dart';
import 'onboarding_screen.dart';

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
  bool _isLoading = false;

  void _submit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isLoading = true);

    bool success = false;
    if (_isLoginTab) {
      success = await auth.login(_phoneController.text, _passwordController.text);
    } else {
      success = await auth.register(
        _phoneController.text,
        _passwordController.text,
        _nameController.text,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BusinessProfileFormScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication failed. Check phone or password.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLoginTab ? "Login" : "Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
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
            const SizedBox(height: 30),
            if (!_isLoginTab) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],
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
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isLoginTab ? "Login" : "Register & Continue"),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Demo bypass for quick hackathon presentation
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

