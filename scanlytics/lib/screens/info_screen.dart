import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOW IT WORKS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildExplanationCard(
              icon: Icons.hub_rounded,
              title: '1. Federated Learning',
              description: 'Instead of sending your data to a central server, the AI Model securely travels to your device, learns locally from the data, and only sends back the improved "knowledge" (weights).',
              color: AppColors.neonGreen,
            ),
            const SizedBox(height: 24),
            _buildExplanationCard(
              icon: Icons.shield_rounded,
              title: '2. 100% Data Privacy',
              description: 'Because your raw health data never leaves your device, absolute privacy is mathematically guaranteed. No one—not even our servers—sees your sensitive data.',
              color: AppColors.neonGreen, 
            ),
            const SizedBox(height: 24),
            _buildExplanationCard(
              icon: Icons.local_hospital_rounded,
              title: '3. Multi-Hospital Scale',
              description: 'The global model aggregates insights across thousands of decentralized nodes. Hospitals collaborate to train a super-intelligent medical AI without ever sharing patient records.',
              color: AppColors.neonGreen,
            ),
            const SizedBox(height: 48),
            GlowButton(
              text: 'I UNDERSTAND',
              color: AppColors.neonGreen,
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard({required IconData icon, required String title, required String description, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: -2)
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(fontSize: 15, color: AppColors.textMain, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
