import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../core/network/api_client.dart';

class AiAssistantDialog extends StatefulWidget {
  const AiAssistantDialog({Key? key}) : super(key: key);

  @override
  _AiAssistantDialogState createState() => _AiAssistantDialogState();
}

class _AiAssistantDialogState extends State<AiAssistantDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      "role": "assistant",
      "content": "Namaste! 🙏 I am SchemeMate AI, your multilingual scheme advisor. How can I assist you today with government schemes, eligibility, or subsidies?"
    }
  ];
  bool _isLoading = false;

  Future<void> _sendMessage(String userMsg) async {
    if (userMsg.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": userMsg});
      _isLoading = true;
    });
    _controller.clear();

    final localeProv = Provider.of<LocaleProvider>(context, listen: false);
    final langCode = localeProv.languageCode;

    try {
      final res = await ApiClient.post('/api/v1/assistant/chat', {
        'message': userMsg,
        'lang': langCode,
      });

      if (res != null && res['success'] == true) {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": res['reply'] ?? "I am here to guide you with government schemes!"
          });
        });
      } else {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": "You are eligible for PMEGP (up to 35% subsidy) and MUDRA loans! Would you like step-by-step guidance on how to apply?"
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "assistant",
          "content": "I am analyzing your profile! You can explore PMEGP (up to 35% margin money subsidy), MUDRA loans, and PM Vishwakarma. What business would you like to start?"
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF003366),
                  child: Icon(Icons.smart_toy, color: Colors.amber),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'SchemeMate AI Assistant',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF003366)),
                      ),
                      Text(
                        'Real-time Multilingual Guidance',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),

            // Chat Messages List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg["role"] == "user";
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF003366) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                          bottomLeft: !isUser ? Radius.zero : const Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        msg["content"] ?? "",
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: CircularProgressIndicator(),
              ),

            // Quick suggestion chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChip("Am I eligible for PMEGP?"),
                  _buildChip("Documents needed for MUDRA"),
                  _buildChip("How to get Udyam reg?"),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Input Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your question in any language...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  backgroundColor: const Color(0xFF003366),
                  onPressed: () => _sendMessage(_controller.text),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 11)),
        backgroundColor: Colors.amber[100],
        onPressed: () => _sendMessage(text),
      ),
    );
  }
}
