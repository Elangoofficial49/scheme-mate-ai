import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/theme/app_theme.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<Map<String, String>> _messages = [
    {
      "sender": "ai",
      "text": "Hello! Welcome to SchemeMate AI. What type of business or enterprise do you run or plan to start?"
    }
  ];

  final _textController = TextEditingController();
  bool _isListeningVoice = false;

  void _sendMessage([String? customText]) async {
    String text = customText ?? _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": text});
      _textController.clear();
    });

    final res = await ApiClient.post("/profile/onboard-dialogue", {
      "user_message": text
    });

    if (res["success"] == true && res["data"] != null) {
      String aiResp = res["data"]["ai_response"] ?? "Thank you for the response.";
      String nextQ = res["data"]["next_question"] ?? "";
      setState(() {
        _messages.add({"sender": "ai", "text": "$aiResp\n\n$nextQ"});
      });
    }
  }

  void _toggleVoiceMic() {
    setState(() {
      _isListeningVoice = !_isListeningVoice;
    });

    if (_isListeningVoice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎤 Listening... Speak now (Tamil / Hindi / English supported)")),
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isListeningVoice) {
          setState(() {
            _isListeningVoice = false;
          });
          _sendMessage("I run a small tailoring shop in Tamil Nadu requiring 2 Lakhs loan.");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Conversational Onboarding"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            },
            child: const Text("Skip to Dashboard", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.primaryBlue.withOpacity(0.08),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppTheme.primaryBlue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Our AI structures your profile step-by-step. No complex forms required!",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg["sender"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.primaryBlue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: TextStyle(
                        fontSize: 15,
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isListeningVoice ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _isListeningVoice ? Colors.red : AppTheme.primaryBlue,
                    size: 30,
                  ),
                  onPressed: _toggleVoiceMic,
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: "Type or tap mic to speak...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppTheme.primaryBlue),
                  onPressed: () => _sendMessage(),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  );
                },
                child: const Text("View My Matched Schemes ->"),
              ),
            ),
          )
        ],
      ),
    );
  }
}

