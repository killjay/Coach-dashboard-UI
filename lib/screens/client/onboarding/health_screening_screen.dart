import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../models/health_screening_model.dart';
import 'lifestyle_goals_screen.dart';

class HealthScreeningScreen extends StatefulWidget {
  const HealthScreeningScreen({super.key});

  @override
  State<HealthScreeningScreen> createState() => _HealthScreeningScreenState();
}

class _HealthScreeningScreenState extends State<HealthScreeningScreen> {
  final Map<String, bool> _conditions = {
    'PCOS': false,
    'Diabetes': false,
    'Thyroid Issues': false,
    'Hypertension': false,
  };
  final TextEditingController _otherConditionsController = TextEditingController();

  @override
  void dispose() {
    _otherConditionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  AppIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => Navigator.of(context).pop(),
                    iconColor: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      'Health Screening',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.info_outline,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.card,
                          title: const Text(
                            'Health Information Privacy',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'Your health information is stored securely and is only accessible to you and your assigned coach. This data helps create a safe and effective fitness plan tailored to your needs.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'OK',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step 2 of 5',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.4,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This information helps your coach create a safe and effective plan tailored to you. Your data is stored securely.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Please select any pre-existing conditions:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // Condition List
                    ..._conditions.keys.map((condition) => _buildConditionItem(condition)),
                    const SizedBox(height: 32),
                    // Other Conditions Section
                    Text(
                      'Other Conditions or Injuries',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _otherConditionsController,
                      maxLines: 4,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                      decoration: InputDecoration(
                        hintText: 'e.g., Past knee surgery, allergies...',
                        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.5),
                            ),
                        filled: true,
                        fillColor: const Color(0xFF22492F),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Continue Button
            Container(
              padding: const EdgeInsets.all(16.0),
              color: AppColors.backgroundDark,
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Continue',
                  onPressed: () async {
                    await _saveHealthData();
                    if (mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LifestyleGoalsScreen(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionItem(String condition) {
    final iconMap = {
      'PCOS': Icons.female,
      'Diabetes': Icons.bloodtype,
      'Thyroid Issues': Icons.medical_services,
      'Hypertension': Icons.favorite,
    };

    final descriptionMap = {
      'PCOS': 'Polycystic Ovary Syndrome',
      'Diabetes': 'Type 1 or 2',
      'Thyroid Issues': 'Hyper or Hypothyroidism',
      'Hypertension': 'High Blood Pressure',
    };

    final isSelected = _conditions[condition] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF22492F),
                borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
              ),
              child: Icon(
                iconMap[condition],
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  Text(
                    descriptionMap[condition] ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  _conditions[condition] = value;
                });
              },
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveHealthData() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();
      final userId = authProvider.user?.uid;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not authenticated. Please sign in again.'),
            ),
          );
        }
        return;
      }

      final healthData = HealthScreeningModel(
        pcos: _conditions['PCOS'] ?? false,
        diabetes: _conditions['Diabetes'] ?? false,
        thyroidIssues: _conditions['Thyroid Issues'] ?? false,
        hypertension: _conditions['Hypertension'] ?? false,
        otherConditions: _otherConditionsController.text.trim().isEmpty
            ? null
            : _otherConditionsController.text.trim(),
      );

      await userProvider.updateClientOnboarding(
        clientId: userId,
        onboardingCompleted: false,
        healthData: healthData.toJson(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving health data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}




