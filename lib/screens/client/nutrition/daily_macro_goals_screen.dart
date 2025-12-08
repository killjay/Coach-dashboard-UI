import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/progress_ring.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/primary_button.dart';
import 'manual_food_logging_screen.dart';

class DailyMacroGoalsScreen extends StatelessWidget {
  const DailyMacroGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    const double eatenCalories = 820.0;
    const double goalCalories = 2500.0;
    const double remainingCalories = goalCalories - eatenCalories;
    const double progress = eatenCalories / goalCalories;

    const double proteinEaten = 65.0;
    const double proteinGoal = 150.0;
    const double carbsEaten = 95.0;
    const double carbsGoal = 300.0;
    const double fatEaten = 25.0;
    const double fatGoal = 80.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: AppIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Nutrition',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
              ),
        ),
        actions: [
          AppIconButton(
            icon: Icons.calendar_today,
            onPressed: () {
              // Navigate to Nutrition History
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nutrition history coming soon'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Central Progress Ring for Calories
            ProgressRing(
              progress: progress,
              size: 200,
              strokeWidth: 16,
              child: Column(
                children: [
                  Text(
                    '${remainingCalories.toInt()}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Calories Left',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryDark,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Calorie Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Eaten',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                    ),
                    Text(
                      '${eatenCalories.toInt()}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.borderWhite10,
                ),
                const SizedBox(width: 32),
                Column(
                  children: [
                    Text(
                      'Goal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                    ),
                    Text(
                      '${goalCalories.toInt()}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Macro Cards
            _buildMacroCard(
              context,
              label: 'Protein',
              eaten: proteinEaten,
              goal: proteinGoal,
              unit: 'g',
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildMacroCard(
              context,
              label: 'Carbs',
              eaten: carbsEaten,
              goal: carbsGoal,
              unit: 'g',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildMacroCard(
              context,
              label: 'Fat',
              eaten: fatEaten,
              goal: fatGoal,
              unit: 'g',
              color: Colors.blue,
            ),
            const SizedBox(height: 32),
            // Log Food Button
            PrimaryButton(
              text: 'Log Food',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ManualFoodLoggingScreen(),
                  ),
                );
              },
              height: 56,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCard(
    BuildContext context, {
    required String label,
    required double eaten,
    required double goal,
    required String unit,
    required Color color,
  }) {
    final progress = (eaten / goal).clamp(0.0, 1.0);

    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              Text(
                '${eaten.toInt()} / ${goal.toInt()} $unit',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primary20,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

