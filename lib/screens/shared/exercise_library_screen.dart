import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_icon_button.dart';
import '../../widgets/common/app_card.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final exercises = [
      'Barbell Bench Press',
      'Squat',
      'Deadlift',
      'Pull Ups',
      'Shoulder Press',
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  AppIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.of(context).pop(),
                    iconColor: isDark ? Colors.white : Colors.black,
                  ),
                  Expanded(
                    child: Text(
                      'Exercise Library',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            // Exercise List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  ...exercises.map((exercise) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: AppCard(
                          backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
                          padding: const EdgeInsets.all(16.0),
                          onTap: () {
                            // Show exercise details
                          },
                          child: Row(
                            children: [
                              Icon(Icons.fitness_center, color: AppColors.primary),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  exercise,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                ),
                              ),
                              Icon(Icons.play_circle_outline, color: AppColors.primary),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




