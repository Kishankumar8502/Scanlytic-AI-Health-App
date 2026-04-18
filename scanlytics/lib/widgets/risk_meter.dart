import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/app_theme.dart';

class CustomCircularMeter extends StatelessWidget {
  final double percentage;
  final String label;
  final Color color;

  const CustomCircularMeter({
    super.key,
    required this.percentage,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: CustomPaint(
              painter: MeterPainter(percentage: percentage, color: color),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: color,
                  shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 20)],
                ),
              ),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 2,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MeterPainter extends CustomPainter {
  final double percentage;
  final Color color;

  MeterPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final trackPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    final glowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    const startAngle = 3 * pi / 4;
    const sweepAngle = 3 * pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    final progressSweep = (percentage / 100) * sweepAngle;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      glowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
