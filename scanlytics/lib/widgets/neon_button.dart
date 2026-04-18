import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlowButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const GlowButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.neonGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
    );
  }
}
