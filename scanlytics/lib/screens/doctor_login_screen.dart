import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import 'doctor_dashboard.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    
    // Simulate slight network delay for better UX feeling
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!mounted) return;
    
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username == 'doctor' && password == '1234') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DoctorDashboard()),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Text('Access Denied: Invalid Credentials'),
            ],
          ),
          backgroundColor: AppColors.neonRed,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SECURE PORTAL')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(color: AppColors.neonGreen.withOpacity(0.2), blurRadius: 30)
                  ]
                ),
                child: const Icon(Icons.shield_rounded, size: 64, color: AppColors.neonGreen),
              ),
              const SizedBox(height: 30),
              const Text(
                'CLINICAL AUTHENTICATION',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: AppColors.neonGreen,
                ),
              ),
              const SizedBox(height: 40),
              
              // Username Field
              _buildAuthField('Username', Icons.person, _usernameController, false),
              const SizedBox(height: 20),
              
              // Password Field
              _buildAuthField('Password', Icons.lock, _passwordController, true),
              const SizedBox(height: 40),
              
              _isLoading 
                ? const CircularProgressIndicator(color: AppColors.neonGreen)
                : GlowButton(
                    text: 'AUTHENTICATE',
                    color: AppColors.neonGreen,
                    onPressed: _login,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthField(String label, IconData icon, TextEditingController controller, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: AppColors.textMain),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.neonGreen.withOpacity(0.7)),
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
