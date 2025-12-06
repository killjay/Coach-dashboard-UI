import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';

class LeaderboardSettingsScreen extends StatefulWidget {
  const LeaderboardSettingsScreen({super.key});

  @override
  State<LeaderboardSettingsScreen> createState() => _LeaderboardSettingsScreenState();
}

class _LeaderboardSettingsScreenState extends State<LeaderboardSettingsScreen> {
  // Activity leaderboards
  bool _dailySteps = true;
  bool _weeklySteps = true;
  bool _monthlySteps = true;
  bool _distanceCovered = false;

  // Workout leaderboards
  bool _workoutConsistency = true;
  bool _totalWorkoutTime = false;
  bool _caloriesBurned = false;

  bool _hasUnsavedChanges = false;

  void _saveSettings() {
    // Save settings logic would go here
    setState(() {
      _hasUnsavedChanges = false;
    });

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings Saved!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _updateToggle(String key, bool value) {
    setState(() {
      switch (key) {
        case 'dailySteps':
          _dailySteps = value;
          break;
        case 'weeklySteps':
          _weeklySteps = value;
          break;
        case 'monthlySteps':
          _monthlySteps = value;
          break;
        case 'distanceCovered':
          _distanceCovered = value;
          break;
        case 'workoutConsistency':
          _workoutConsistency = value;
          break;
        case 'totalWorkoutTime':
          _totalWorkoutTime = value;
          break;
        case 'caloriesBurned':
          _caloriesBurned = value;
          break;
      }
      _hasUnsavedChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  AppIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () {
                      if (_hasUnsavedChanges) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.cardDark,
                            title: const Text('Discard Changes?', style: TextStyle(color: Colors.white)),
                            content: const Text(
                              'You have unsaved changes. Are you sure you want to leave?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text('Discard', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    iconColor: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      'Leaderboard Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: _saveSettings,
                    child: Text(
                      'Save',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
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
                    // Instructional Text
                    Text(
                      'Choose which leaderboards are visible to your community.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF8E8E93),
                          ),
                    ),
                    const SizedBox(height: 32),
                    // Activity Section
                    Text(
                      'Activity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildToggleCard('Daily Steps', _dailySteps, (value) => _updateToggle('dailySteps', value)),
                    const SizedBox(height: 12),
                    _buildToggleCard('Weekly Steps', _weeklySteps, (value) => _updateToggle('weeklySteps', value)),
                    const SizedBox(height: 12),
                    _buildToggleCard('Monthly Steps', _monthlySteps, (value) => _updateToggle('monthlySteps', value)),
                    const SizedBox(height: 12),
                    _buildToggleCard('Distance Covered', _distanceCovered, (value) => _updateToggle('distanceCovered', value)),
                    const SizedBox(height: 32),
                    // Workouts Section
                    Text(
                      'Workouts',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildToggleCard('Workout Consistency', _workoutConsistency, (value) => _updateToggle('workoutConsistency', value)),
                    const SizedBox(height: 12),
                    _buildToggleCard('Total Workout Time', _totalWorkoutTime, (value) => _updateToggle('totalWorkoutTime', value)),
                    const SizedBox(height: 12),
                    _buildToggleCard('Calories Burned', _caloriesBurned, (value) => _updateToggle('caloriesBurned', value)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleCard(String label, bool value, Function(bool) onChanged) {
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
