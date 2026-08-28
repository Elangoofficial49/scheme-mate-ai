import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> _auditLogs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAuditLogs();
  }

  void _fetchAuditLogs() async {
    setState(() => _isLoading = true);
    final res = await ApiClient.get("/admin/audit-logs");
    if (res["success"] == true && res["data"] != null) {
      setState(() {
        _auditLogs = res["data"];
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Portal & Audit Trail")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("System Audit Trail & Security Events", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_auditLogs.isEmpty)
              const Text("No audit log records found.")
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _auditLogs.length,
                  itemBuilder: (context, index) {
                    final log = _auditLogs[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.shield_outlined, color: AppTheme.primaryBlue),
                        title: Text(log["action"] ?? "ACTION"),
                        subtitle: Text("User: ${log['user_id'] ?? 'Anonymous'} | ${log['created_at']}"),
                        trailing: const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 18),
                      ),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}

