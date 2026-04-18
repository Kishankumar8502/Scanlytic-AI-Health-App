import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  String gender = 'Male';
  double chestPain = 0;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _cholController = TextEditingController();
  final _hrController = TextEditingController();
  final _oldpeakController = TextEditingController();

  bool get _isFormValid {
    if (_nameController.text.trim().isEmpty ||
        _ageController.text.isEmpty ||
        _systolicController.text.isEmpty ||
        _diastolicController.text.isEmpty ||
        _cholController.text.isEmpty ||
        _hrController.text.isEmpty ||
        _oldpeakController.text.isEmpty) {
      return false;
    }

    // Check ranges
    final age = double.tryParse(_ageController.text);
    final sys = double.tryParse(_systolicController.text);
    final dia = double.tryParse(_diastolicController.text);
    final chol = double.tryParse(_cholController.text);
    final hr = double.tryParse(_hrController.text);
    final oldpeak = double.tryParse(_oldpeakController.text);

    if (age == null || age < 1 || age > 100) return false;
    if (sys == null || sys < 90 || sys > 180) return false;
    if (dia == null || dia < 60 || dia > 120) return false;
    if (chol == null || chol < 100 || chol > 400) return false;
    if (hr == null || hr < 60 || hr > 220) return false;
    if (oldpeak == null || oldpeak < 0 || oldpeak > 6) return false;

    return true;
  }

  void _onInputChanged() {
    setState(() {}); // Re-build to dynamically evaluate button disabled state
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onInputChanged);
    _ageController.addListener(_onInputChanged);
    _systolicController.addListener(_onInputChanged);
    _diastolicController.addListener(_onInputChanged);
    _cholController.addListener(_onInputChanged);
    _hrController.addListener(_onInputChanged);
    _oldpeakController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _cholController.dispose();
    _hrController.dispose();
    _oldpeakController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid data within the ranges in all fields.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final double age = double.parse(_ageController.text);
      final double sex = gender == 'Male' ? 1.0 : 0.0;
      final double sysBP = double.parse(_systolicController.text);
      final double chol = double.parse(_cholController.text);
      final double maxHr = double.parse(_hrController.text);
      final double oldpeak = double.parse(_oldpeakController.text);

      // 13 parameters passed directly per prompt specification
      final List<double> features = [
        age,
        sex,
        chestPain,
        sysBP, // using systolic directly for trestbps
        chol,
        0.0, // fbs
        0.0, // restecg
        maxHr,
        0.0, // exang
        oldpeak,
        0.0, // slope
        0.0, // ca
        1.0, // thal
      ];

      // Generate dynamic patient_id
      final String patientId =
          'PT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 11)}';
      final String patientName = _nameController.text.trim();

      print('\n================ API REQUEST ================');
      print('Endpoint URL: ${ApiService.predictUrl}');
      print('Patient ID: $patientId ($patientName)');
      print('Payload Features Array: $features');
      print('=============================================\n');

      final result = await ApiService.predictRisk(
        patientId,
        patientName,
        features,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            riskLevel: (result['risk'] as num).toDouble(),
            prediction: result['prediction'] as int,
            advice: result['advice'] as String? ?? 'No advice provided.',
            patientId: patientId,
            patientName: patientName,
            alert: result['alert'] as bool? ?? false,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.neonRed,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showInfoPopup(String title, String explanation) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.neonGreen.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.neonGreen,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neonGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  explanation,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                GlowButton(
                  text: 'GOT IT',
                  color: AppColors.neonGreen,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PATIENT DATA')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextInput(
                'Patient Name',
                Icons.person,
                _nameController,
                hint: 'e.g. Jane Doe',
              ),
              const SizedBox(height: 20),
              _buildDropdown(),
              const SizedBox(height: 20),
              _buildNumInput(
                'Age (1-100)',
                Icons.calendar_today,
                _ageController,
                hint: 'e.g. 45',
              ),
              const SizedBox(height: 20),
              _buildSlider(
                'Chest Pain Type (0-3)',
                chestPain,
                3,
                (val) => setState(() => chestPain = val),
                hint: '0 = No pain, 1 = Mild, 2 = Moderate, 3 = Severe',
                infoTitle: 'Chest Pain Type',
                infoText:
                    'Categorizes the severity and type of chest pain experienced. Higher numbers typically correlate with more significant angina symptoms.',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildNumInput(
                      'Systolic BP\n(90-180)',
                      Icons.speed,
                      _systolicController,
                      hint: 'e.g. 120 (Normal: <120)',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumInput(
                      'Diastolic BP\n(60-120)',
                      Icons.speed,
                      _diastolicController,
                      hint: 'e.g. 80 (Normal: <80)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildNumInput(
                'Cholesterol (100-400)',
                Icons.monitor_heart,
                _cholController,
                hint: 'Normal: 150–240',
                hasInfo: true,
                infoTitle: 'Serum Cholesterol',
                infoText:
                    'Measures total cholesterol levels in mg/dl. Extreme levels can significantly accelerate arterial plaque buildup.',
              ),
              const SizedBox(height: 20),
              _buildNumInput(
                'Max Heart Rate (60-220)',
                Icons.favorite,
                _hrController,
                hint: 'e.g. 150',
              ),
              const SizedBox(height: 20),
              _buildNumInput(
                'ST Depression (Oldpeak)',
                Icons.show_chart,
                _oldpeakController,
                hint: 'e.g. 1.5',
                hasInfo: true,
                infoTitle: 'Oldpeak (ST Depression)',
                infoText:
                    'Oldpeak indicates heart stress during exercise relative to rest. Higher values may indicate severe heart problems or decreased oxygen flow.',
              ),
              const SizedBox(height: 40),

              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.neonGreen)
                  : GlowButton(
                      text: 'ANALYZE RISK',
                      color: _isFormValid ? AppColors.neonGreen : Colors.grey,
                      onPressed: _submitData,
                    ),

              const SizedBox(height: 20),

              TextButton.icon(
                onPressed: _showTermsGlossary,
                icon: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.neonGreen,
                  size: 20,
                ),
                label: Text(
                  "Don't understand these terms?",
                  style: TextStyle(
                    color: AppColors.neonGreen.withOpacity(0.8),
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.neonGreen.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsGlossary() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppColors.neonGreen.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonGreen.withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: -5,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Medical Terms Explained',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 30),

              _buildGlossaryRow(
                Icons.monitor_heart,
                'Chest Pain',
                'Type of chest discomfort experienced.',
              ),
              _buildGlossaryRow(
                Icons.water_drop,
                'Cholesterol',
                'Fat level in blood. High levels can cause blockages.',
              ),
              _buildGlossaryRow(
                Icons.show_chart,
                'Oldpeak',
                'Heart stress indicator. Measures abnormal stress during exercise.',
              ),
              _buildGlossaryRow(
                Icons.favorite,
                'Max Heart Rate',
                'Maximum heart pumping capacity measured during peak exertion.',
              ),

              const SizedBox(height: 40),
              GlowButton(
                text: 'CLOSE',
                color: AppColors.neonGreen,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlossaryRow(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
            ),
            child: Icon(icon, color: AppColors.neonGreen, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: AppColors.textMuted.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(
    String label,
    IconData icon,
    TextEditingController controller, {
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.name,
        style: const TextStyle(color: AppColors.textMain),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Icon(icon, color: AppColors.neonGreen.withOpacity(0.7)),
          ),
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.3)),
          labelStyle: TextStyle(
            color: AppColors.textMuted.withOpacity(0.7),
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildNumInput(
    String label,
    IconData icon,
    TextEditingController controller, {
    String? hint,
    bool hasInfo = false,
    String? infoTitle,
    String? infoText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(color: AppColors.textMain),
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Icon(
                    icon,
                    color: AppColors.neonGreen.withOpacity(0.7),
                  ),
                ),
                labelText: label,
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.textMuted.withOpacity(0.3),
                ),
                labelStyle: TextStyle(
                  color: AppColors.textMuted.withOpacity(0.7),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          if (hasInfo)
            IconButton(
              icon: Icon(
                Icons.help_outline_rounded,
                color: AppColors.textMuted.withOpacity(0.6),
              ),
              onPressed: () =>
                  _showInfoPopup(infoTitle ?? 'Information', infoText ?? ''),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: gender,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          style: const TextStyle(color: AppColors.textMain),
          items: ['Male', 'Female'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(
                    value == 'Male' ? Icons.male : Icons.female,
                    color: AppColors.neonGreen.withOpacity(0.7),
                  ),
                  const SizedBox(width: 10),
                  Text(value),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => gender = val);
          },
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double max,
    ValueChanged<double> onChanged, {
    String? hint,
    String? infoTitle,
    String? infoText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$label: ${value.toInt()}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              if (infoTitle != null && infoText != null)
                InkWell(
                  onTap: () => _showInfoPopup(infoTitle, infoText),
                  child: Icon(
                    Icons.help_outline_rounded,
                    color: AppColors.textMuted.withOpacity(0.6),
                    size: 20,
                  ),
                ),
            ],
          ),
          Slider(
            value: value,
            max: max,
            divisions: max.toInt(),
            activeColor: AppColors.neonGreen,
            inactiveColor: AppColors.background,
            onChanged: onChanged,
          ),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: Text(
                hint,
                style: TextStyle(
                  color: AppColors.textMuted.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
