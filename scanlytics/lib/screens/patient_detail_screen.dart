import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final double risk = (patient['risk'] as num).toDouble();
    final bool isHigh = risk > 70;
    final Color color = isHigh ? AppColors.neonRed : AppColors.neonGreen;
    
    // Fallbacks
    final String patientName = patient['patient_name'] as String? ?? 'Unknown Patient';
    final String statusText = patient['status'] as String? ?? 'Pending';
    final String advice = patient['advice'] as String? ?? (isHigh ? 'Immediate medical consultation required. Monitor vitals closely.' : 'Patient is stable. Continue regular checkups.');
    
    // Extract input data safely
    final inputData = patient['input_data'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text('$patientName Details'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Risk Meter Graph
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'RISK ASSESSMENT',
                    style: TextStyle(color: AppColors.textMuted, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: risk / 100,
                          strokeWidth: 12,
                          color: color,
                          backgroundColor: AppColors.background,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${risk.toInt()}%',
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: color),
                          ),
                          Text(
                            statusText.toUpperCase(),
                            style: TextStyle(color: color, fontWeight: FontWeight.w600),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Medical Advice
            const Text('MEDICAL ADVICE', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: color, width: 4)),
              ),
              child: Text(
                advice,
                style: const TextStyle(color: AppColors.textMain, fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Input Data
            const Text('INPUT PARAMETERS', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: inputData.isEmpty 
                  ? const Text('No detailed input parameters available.', style: TextStyle(color: AppColors.textMuted))
                  : Column(
                      children: inputData.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key.toString().toUpperCase(), style: const TextStyle(color: AppColors.textMuted)),
                            Text(e.value.toString(), style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
