import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import 'input_screen.dart';
import 'doctor_login_screen.dart';
import 'info_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.textMain),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InfoScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withOpacity(0.3),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.security, size: 50, color: AppColors.neonGreen),
              ),
              const SizedBox(height: 30),
              
              // New Title
              const Text(
                'IngreSight AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppColors.neonGreen,
                ),
              ),
              const SizedBox(height: 10),
              
              // Subtitle
              Text(
                'Federated Healthcare System',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textMuted.withOpacity(0.8),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 60),
              
              // Prompt
              const Text(
                'Select Your Role',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMain,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 30),
              
              // Patient Button
              GlowButton(
                text: 'I AM PATIENT',
                color: AppColors.neonGreen,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InputScreen()),
                  );
                },
              ),
              const SizedBox(height: 25),
              
              // Doctor Button
              GlowButton(
                text: 'I AM DOCTOR',
                color: AppColors.neonGreen,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DoctorLoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
