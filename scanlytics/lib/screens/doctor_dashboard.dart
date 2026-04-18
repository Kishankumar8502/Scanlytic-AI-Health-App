import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'patient_detail_screen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  List<dynamic> _patients = [];
  bool _isLoading = true;
  String _error = '';
  Timer? _timer;
  String _filter = 'All'; // 'All' or 'High Risk'

  @override
  void initState() {
    super.initState();
    _fetchPatients();
    // Auto refresh every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchPatients(showLoader: false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPatients({bool showLoader = true}) async {
    if (showLoader && _patients.isEmpty) {
      setState(() {
        _isLoading = true;
        _error = '';
      });
    }

    try {
      final data = await ApiService.getDoctorDashboard();
      
      // Sort patients: highest risk first
      data.sort((a, b) => (b['risk'] as double).compareTo(a['risk'] as double));
      
      if (mounted) {
        setState(() {
          _patients = data;
          _error = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted && showLoader) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPatients = _patients.length;
    int highRiskCount = _patients.where((p) => (p['risk'] as num).toDouble() > 70).length;
    int lowRiskCount = totalPatients - highRiskCount;

    List<dynamic> displayedPatients = _patients;
    if (_filter == 'High Risk') {
      displayedPatients = _patients.where((p) => (p['risk'] as num).toDouble() > 70).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PATIENT MONITOR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: AppColors.neonRed),
            tooltip: 'Clear All Data',
            onPressed: () async {
              final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: const Text('Clear All Data', style: TextStyle(color: AppColors.neonRed)),
                content: const Text('Are you sure you want to permanently delete all patient records?', style: TextStyle(color: AppColors.textMain)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: AppColors.neonRed))),
                ]
              ));
              
              if (confirm == true) {
                await ApiService.deleteAllPatients();
                _fetchPatients();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing Data...'),
                  duration: Duration(seconds: 1),
                  backgroundColor: AppColors.neonGreen,
                ),
              );
              _fetchPatients();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Federated AI Active Badge
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            width: double.infinity,
            color: AppColors.neonGreen.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hub, color: AppColors.neonGreen, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'FEDERATED AI ACTIVE',
                  style: TextStyle(
                    color: AppColors.neonGreen,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildSummaryCard('Total', totalPatients.toString(), AppColors.textMain),
                const SizedBox(width: 10),
                _buildSummaryCard('High Risk', highRiskCount.toString(), AppColors.neonRed),
                const SizedBox(width: 10),
                _buildSummaryCard('Low Risk', lowRiskCount.toString(), AppColors.neonGreen),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterButton('All', _filter == 'All'),
                const SizedBox(width: 10),
                _buildFilterButton('High Risk', _filter == 'High Risk'),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
          Expanded(
            child: _isLoading && _patients.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.neonGreen))
                : _error.isNotEmpty && _patients.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'Error: $_error',
                            style: const TextStyle(color: AppColors.neonRed),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchPatients,
                        color: AppColors.neonGreen,
                        backgroundColor: AppColors.surface,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: displayedPatients.length,
                          itemBuilder: (context, index) {
                            final p = displayedPatients[index];
                            return PatientCard(
                              patient: p,
                              onDelete: () async {
                                final patientId = p['patient_id'] as String? ?? p['id'] as String? ?? '';
                                if (patientId.isNotEmpty) {
                                  await ApiService.deletePatient(patientId);
                                  _fetchPatients();
                                }
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _filter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonGreen.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.neonGreen : AppColors.border),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.neonGreen : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class PatientCard extends StatefulWidget {
  final Map<String, dynamic> patient;
  final VoidCallback onDelete;

  const PatientCard({super.key, required this.patient, required this.onDelete});

  @override
  State<PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<PatientCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // 1 second pulse
    );
    _glowAnimation = Tween<double>(begin: 0.1, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    double risk = (widget.patient['risk'] as num?)?.toDouble() ?? 0;
    if (risk > 70) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PatientCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    double risk = (widget.patient['risk'] as num?)?.toDouble() ?? 0;
    if (risk > 70) {
      if (!_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      }
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double risk = (widget.patient['risk'] as num).toDouble();
    final String patientId = widget.patient['patient_id'] as String? ?? widget.patient['id'] as String? ?? 'PT-xxxx';
    final String patientName = widget.patient['patient_name'] as String? ?? 'Unknown Patient';
    final String statusText = widget.patient['status'] as String? ?? 'Pending';
    final String timestamp = widget.patient['timestamp'] as String? ?? 'Just now';
    
    final bool isHigh = risk > 70;
    final Color color = isHigh ? AppColors.neonRed : AppColors.neonGreen;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        double glowOpacity = isHigh ? _glowAnimation.value : 0.05;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(isHigh ? glowOpacity + 0.2 : 0.5)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(glowOpacity),
                blurRadius: isHigh ? 20 : 8,
                spreadRadius: isHigh ? 4 : 1,
              )
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(isHigh ? glowOpacity : 0.4), blurRadius: isHigh ? 15 : 5)
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '${risk.toInt()}%',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    patientName,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  patientId,
                  style: TextStyle(
                    color: AppColors.textMuted.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    statusText.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '• $timestamp',
                      style: TextStyle(
                        color: AppColors.textMuted.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.neonRed),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: const Text('Delete Patient', style: TextStyle(color: AppColors.neonRed)),
                      content: const Text('Remove this patient record?', style: TextStyle(color: AppColors.textMain)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: AppColors.neonRed))),
                      ]
                    ));
                    if (confirm == true) {
                      widget.onDelete();
                    }
                  },
                ),
                Icon(Icons.arrow_forward_ios, color: AppColors.textMuted.withOpacity(0.3)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientDetailScreen(patient: widget.patient),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
