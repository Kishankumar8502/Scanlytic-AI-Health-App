import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';

class ResultScreen extends StatefulWidget {
  final double riskLevel;
  final int prediction;
  final String advice;
  final String patientId;
  final String patientName;
  final bool alert;
  
  const ResultScreen({
    super.key, 
    required this.riskLevel, 
    required this.prediction,
    required this.advice,
    required this.patientId,
    required this.patientName,
    this.alert = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  bool _isCalculating = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // Smooth loading animation before reveal
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCalculating = false;
        });
        _fadeController.forward();
        
        if (widget.alert) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showHighRiskPopup();
          });
        }
      }
    });
  }

  void _showHighRiskPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.neonRed, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonRed.withOpacity(0.1),
                  ),
                  child: const Icon(Icons.warning_rounded, color: AppColors.neonRed, size: 60),
                ),
                const SizedBox(height: 24),
                const Text(
                  '⚠ High Risk Detected!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neonRed,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'This patient exhibits critical patterns. Immediate intervention is highly recommended.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textMain,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                GlowButton(
                  text: 'ACKNOWLEDGE',
                  color: AppColors.neonRed,
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isHighRisk = widget.prediction == 1;
    final Color mainColor = isHighRisk ? AppColors.neonRed : AppColors.neonGreen;
    final String statusText = isHighRisk ? 'HIGH RISK' : 'LOW RISK';

    return Scaffold(
      appBar: AppBar(title: const Text('ANALYSIS RESULT')),
      body: _isCalculating 
        ? _buildLoadingState() 
        : _buildResultReveal(mainColor, statusText),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.neonGreen),
          const SizedBox(height: 24),
          const Text(
            'Analyzing patient data...',
            style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Running through federated learning models',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResultReveal(Color mainColor, String statusText) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Patient Name & ID
            Text(
              widget.patientName,
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Patient ID: ${widget.patientId}',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40),

            // Big Risk %
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: mainColor, width: 4),
                boxShadow: [
                  BoxShadow(color: mainColor.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '${widget.riskLevel.toInt()}%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Visual Meter: Green to Red Gradient Pointer
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Risk Visualizer', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
            ),
            const SizedBox(height: 16),
            _buildGradientMeter(),
            const SizedBox(height: 40),

            // Advice Clearly
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Clinical Advice', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: mainColor, width: 6)),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: -2)
                ],
              ),
              child: Text(
                widget.advice,
                style: const TextStyle(color: AppColors.textMain, height: 1.6, fontSize: 16),
              ),
            ),

            const SizedBox(height: 40),
            
            // Send to Doctor Button
            GlowButton(
              text: 'SEND TO DOCTOR',
              color: AppColors.neonGreen,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('Data for ${widget.patientName} securely transmitted.', 
                          style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.neonGreen,
                    duration: const Duration(seconds: 3),
                  ),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text(
                'DISCARD & GO BACK',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGradientMeter() {
    double pointerPosition = widget.riskLevel / 100.0;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        // Icon is 24px wide, half is 12px
        double leftPadding = (totalWidth * pointerPosition) - 12;
        if (leftPadding < 0) leftPadding = 0;
        if (leftPadding > totalWidth - 24) leftPadding = totalWidth - 24;

        return Column(
          children: [
            // Pointer row
            SizedBox(
              height: 24,
              child: Stack(
                children: [
                  Positioned(
                    left: leftPadding,
                    child: const Icon(Icons.arrow_drop_down, size: 30, color: AppColors.textMain),
                  )
                ],
              ),
            ),
            // Gradient bar
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [AppColors.neonGreen, Colors.orange, AppColors.neonRed],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Safe', style: TextStyle(color: AppColors.neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                Text('Moderate', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                Text('Critical', style: TextStyle(color: AppColors.neonRed, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        );
      }
    );
  }
}
