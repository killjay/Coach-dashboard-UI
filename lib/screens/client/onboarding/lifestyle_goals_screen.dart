import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../dashboard/today_view_screen.dart';

class LifestyleGoalsScreen extends StatefulWidget {
  const LifestyleGoalsScreen({super.key});

  @override
  State<LifestyleGoalsScreen> createState() => _LifestyleGoalsScreenState();
}

class _LifestyleGoalsScreenState extends State<LifestyleGoalsScreen> {
  String? _selectedActivityLevel;
  String? _selectedFitnessGoal;

  final Map<String, String> _activityLevels = {
    'Sedentary': 'Little to no exercise, desk job',
    'Lightly Active': 'Light exercise 1-3 days/week',
    'Moderately Active': 'Moderate exercise 3-5 days/week',
    'Very Active': 'Hard exercise 6-7 days/week',
    'Extremely Active': 'Physical job or 2x training per day',
  };

  final Map<String, String> _fitnessGoals = {
    'Fat Loss': 'Reduce body fat and lose weight',
    'Muscle Gain': 'Build muscle and increase strength',
    'Maintenance': 'Maintain current physique and fitness',
    'Performance': 'Improve athletic performance',
    'General Health': 'Improve overall health and wellness',
  };

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
                      'Lifestyle & Goals',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
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
                    // Activity Level Section
                    Text(
                      'How active are you on a typical day?',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ..._activityLevels.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildOptionCard(
                            title: entry.key,
                            description: entry.value,
                            isSelected: _selectedActivityLevel == entry.key,
                            onTap: () {
                              setState(() => _selectedActivityLevel = entry.key);
                            },
                          ),
                        )),
                    const SizedBox(height: 32),
                    // Fitness Goal Section
                    Text(
                      'What is your main fitness goal?',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ..._fitnessGoals.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildOptionCard(
                            title: entry.key,
                            description: entry.value,
                            isSelected: _selectedFitnessGoal == entry.key,
                            onTap: () {
                              setState(() => _selectedFitnessGoal = entry.key);
                            },
                          ),
                        )),
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
                  onPressed: (_selectedActivityLevel != null &&
                          _selectedFitnessGoal != null)
                      ? () {
                          // Save onboarding data and navigate to dashboard
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const TodayViewScreen(),
                            ),
                            (route) => false, // Remove all previous routes
                          );
                        }
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary20
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
