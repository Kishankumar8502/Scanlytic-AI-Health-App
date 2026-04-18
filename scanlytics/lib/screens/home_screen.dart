import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/risk_meter.dart';
import '../widgets/neon_button.dart';
import 'input_screen.dart';
import 'doctor_dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HEALTH RISK MONITOR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DoctorDashboard()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const CustomCircularMeter(percentage: 25, label: 'Low', color: AppColors.neonGreen),
            _buildStatusLabels(),
            GlowButton(
              text: 'CHECK HEALTH',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InputScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statusDot('Low', AppColors.neonGreen),
        _statusDot('Medium', Colors.amber),
        _statusDot('High', AppColors.neonRed),
      ],
    );
  }

  Widget _statusDot(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [BoxShadow(color: color.withOpacity(0.8), blurRadius: 8)],
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: AppColors.textMuted)),
      ],
    );
  }
}
