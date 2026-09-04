import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class GovFooter extends StatelessWidget {
  const GovFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF071C2E), // Dark Official Footer
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // Partner & Governance Initiatives Row
          Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 20,
            runSpacing: 16,
            children: [
              _buildGovTag("🇮🇳 Digital India", "Power To Empower"),
              _buildGovTag("🏛️ MyGov.in", "Citizen Engagement"),
              _buildGovTag("⚡ SIH 2026", "AI Enterprise Platform"),
              _buildGovTag("🔒 GIGW Compliant", "Level AA Certified"),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),

          // Copyright & Disclaimer
          const Text(
            "Website Content Managed by Ministry of Micro, Small & Medium Enterprises, Government of India.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          const Text(
            "Designed, Developed and Hosted by SchemeMate AI National Innovation Team • Version 2.0.4",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 12),

          // Quick Links
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            children: [
              _buildFooterLink("Terms of Service"),
              _buildFooterLink("Privacy Policy"),
              _buildFooterLink("Accessibility Statement"),
              _buildFooterLink("Helpdesk & Grievance Cell"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGovTag(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(color: AppTheme.accentSaffron, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 11, decoration: TextDecoration.underline),
      ),
    );
  }
}
