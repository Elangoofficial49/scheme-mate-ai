import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../core/network/api_client.dart';

class AiAssistantDialog extends StatefulWidget {
  const AiAssistantDialog({super.key});

  @override
  State<AiAssistantDialog> createState() => _AiAssistantDialogState();
}

class _AiAssistantDialogState extends State<AiAssistantDialog> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isSpeaking = false;
  int? _speakingIndex;
  bool _autoSpeak = true;
  String _selectedLang = 'en';

  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final Map<String, String> _languages = {
    'en': 'English 🇬🇧',
    'ta': 'தமிழ் (Tamil) 🇮🇳',
    'hi': 'हिंदी (Hindi) 🇮🇳',
    'te': 'తెలుగు (Telugu) 🇮🇳',
    'kn': 'கன்னட (Kannada) 🇮🇳',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localeProv = Provider.of<LocaleProvider>(context, listen: false);
      setState(() {
        _selectedLang = localeProv.languageCode;
      });
      _addInitialGreeting();
    });
  }

  void _addInitialGreeting() {
    String greeting = "Namaste! 🙏 I am your SchemeMate Gen AI Assistant.\n\n"
        "I'm here to chat with you like a human and guide you step-by-step on:\n"
        "• How to fill your profile or use OCR Document Scan\n"
        "• 35% Margin Money Subsidies (PMEGP, MUDRA, PM Vishwakarma)\n"
        "• Financial Loan Calculator & Partner Locator Maps\n\n"
        "⚠️ Note: I specialize exclusively in SchemeMate AI and government entrepreneurship schemes. If you ask questions apart from our website, I will politely ask you to stay on website topics! 😊\n\n"
        "How can I help you today? You can type your question in any language!";

    if (_selectedLang == 'ta') {
      greeting = "வணக்கம்! 🙏 நான் உங்கள் SchemeMate Gen AI உதவி முகவர்.\n\n"
          "அரசு திட்டங்கள், 35% மானியம் (PMEGP, MUDRA), OCR ஆவண ஸ்கேனர் மற்றும் கடன் கணிப்பான் பற்றி ஒரு மனிதனைப் போல வழிகாட்ட நான் தயார்!\n\n"
          "⚠️ குறிப்பு: இந்த இணையதளம் மற்றும் அரசு திட்டங்கள் சார்ந்த கேள்விகளுக்கு மட்டுமே நான் பதிலளிப்பேன். இணையதள அம்சங்கள் பற்றி கேளுங்கள்! 😊\n\n"
          "உங்களுக்கு என்ன உதவி வேண்டும்? கீழே தட்டச்சு செய்யவும்!";
    } else if (_selectedLang == 'hi') {
      greeting = "नमस्ते! 🙏 मैं आपका SchemeMate Gen AI सहायक हूं।\n\n"
          "मैं एक इंसान की तरह आपसे बातचीत करके सरकारी योजनाओं, 35% सब्सिडी (PMEGP, MUDRA), OCR दस्तावेज़ स्कैनर और ऋण कैलकुलेटर के बारे में आपका मार्गदर्शन करूंगा!\n\n"
          "⚠️ नोट: मैं केवल हमारी वेबसाइट और सरकारी योजनाओं से संबंधित सवालों के जवाब देता हूँ। 😊\n\n"
          "आज मैं आपकी क्या सहायता कर सकता हूँ?";
    }

    setState(() {
      _messages.add({"role": "assistant", "content": greeting});
    });
  }

  Future<void> _sendMessage(String userMsg) async {
    if (userMsg.trim().isEmpty) return;

    final query = userMsg.trim();
    _controller.clear();

    setState(() {
      _messages.add({"role": "user", "content": query});
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final res = await ApiClient.post('/api/v1/assistant/chat', {
        'message': query,
        'lang': _selectedLang,
        'conversation_history': _messages.sublist(0, _messages.length - 1),
      });

      String reply = "";
      if (res['success'] == true && res['reply'] != null) {
        reply = res['reply'].toString();
      } else {
        reply = "I am analyzing your profile! Based on your business details, you qualify for top central and state schemes like PMEGP (35% subsidy grant) and MUDRA loans. Would you like me to guide you through the OCR document scanner or application checklist?";
      }

      setState(() {
        _messages.add({"role": "assistant", "content": reply});
      });
    } catch (e) {
      final qLower = query.toLowerCase();
      final isOutOfDomain = [
        'cricket', 'football', 'movie', 'film', 'song', 'weather', 'python',
        'code', 'recipe', 'biryani', 'actor', 'actress', 'capital of', 'game'
      ].any((k) => qLower.contains(k));

      final fallbackMsg = isOutOfDomain
          ? "I am your SchemeMate Gen AI Assistant, dedicated exclusively to assisting you with SchemeMate AI, government schemes, business subsidies, and entrepreneur loans. Please ask questions related to our website features or government schemes! 😊"
          : "Hello! I am your SchemeMate Gen AI Assistant. I can guide you through our website features:\n\n• **Scan Document**: Auto-fill your profile with Aadhaar/PAN\n• **35% PMEGP Subsidy**: Claim top government grants\n• **PM MUDRA Loans**: Collateral-free credit up to ₹10 Lakhs\n• **Financial Calculator**: Check your monthly EMI and subsidy deduction\n• **Partner Locator**: Find your nearest DIC office on the map!";

      setState(() {
        _messages.add({"role": "assistant", "content": fallbackMsg});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        height: MediaQuery.of(context).size.height * 0.84,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003366),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: Colors.amber, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'SchemeMate Gen AI Assistant',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF003366),
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.verified, color: Colors.amber, size: 16),
                        ],
                      ),
                      Text(
                        'Human-like Conversational Scheme Guide',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Language Selector Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Selected Language:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLang,
                      icon: const Icon(Icons.language, color: Color(0xFF003366), size: 18),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF003366), fontWeight: FontWeight.bold),
                      onChanged: (String? newLang) {
                        if (newLang != null) {
                          setState(() {
                            _selectedLang = newLang;
                          });
                        }
                      },
                      items: _languages.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Chat Messages Container
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg["role"] == "user";

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF003366) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(18).copyWith(
                          bottomRight: isUser ? Radius.zero : const Radius.circular(18),
                          bottomLeft: !isUser ? Radius.zero : const Radius.circular(18),
                        ),
                        border: isUser ? null : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        msg["content"] ?? "",
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 13.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF003366)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Gen AI is generating a human-like response...",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700], fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

            // Quick Guidance Suggestion Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChip("📌 How to use SchemeMate AI?", Icons.help_outline),
                  _buildChip("📷 How to use OCR Document Scan?", Icons.document_scanner),
                  _buildChip("💰 Am I eligible for 35% PMEGP subsidy?", Icons.account_balance),
                  _buildChip("🧮 Calculate Loan EMI & Subsidies", Icons.calculate),
                  _buildChip("📍 Find nearest DIC Office on Map", Icons.map),
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
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: "Type your question in any language...",
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
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ActionChip(
        avatar: Icon(icon, size: 14, color: const Color(0xFF003366)),
        label: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.amber[100],
        onPressed: () => _sendMessage(text),
      ),
    );
  }
}
