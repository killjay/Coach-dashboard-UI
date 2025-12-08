import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/progress_ring.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/diet_service.dart';
import '../../../models/diet_plan_model.dart';
import '../../../models/food_log_model.dart';
import 'manual_food_logging_screen.dart';

class DailyMacroGoalsScreen extends StatefulWidget {
  const DailyMacroGoalsScreen({super.key});

  @override
  State<DailyMacroGoalsScreen> createState() => _DailyMacroGoalsScreenState();
}

class _DailyMacroGoalsScreenState extends State<DailyMacroGoalsScreen> {
  final DietService _dietService = DietService();
  
  DietPlanModel? _dietPlan;
  FoodLogModel? _foodLog;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final clientId = authProvider.user?.uid;
    
    if (clientId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    try {
      // Load assigned diet
      final dietResult = await _dietService.getAssignedDiet(clientId);
      if (dietResult.isSuccess && dietResult.dataOrNull != null) {
        final assignedDiet = dietResult.dataOrNull!;
        final planResult = await _dietService.getPlan(assignedDiet.planId);
        if (planResult.isSuccess && planResult.dataOrNull != null) {
          _dietPlan = planResult.dataOrNull;
        }
      }

      // Load today's food log
      final foodLogResult = await _dietService.getDailyMacros(clientId, startOfDay);
      if (foodLogResult.isSuccess && foodLogResult.dataOrNull != null) {
        _foodLog = foodLogResult.dataOrNull;
      }
    } catch (e) {
      print('Error loading macro data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double get _goalCalories => _dietPlan?.calories.toDouble() ?? 0.0;
  double get _eatenCalories => _foodLog?.totalCalories ?? 0.0;
  double get _remainingCalories => (_goalCalories - _eatenCalories).clamp(0.0, double.infinity);
  double get _calorieProgress => _goalCalories > 0 ? (_eatenCalories / _goalCalories).clamp(0.0, 1.0) : 0.0;

  double get _proteinGoal => _dietPlan?.protein ?? 0.0;
  double get _proteinEaten => _foodLog?.totalProtein ?? 0.0;

  double get _carbsGoal => _dietPlan?.carbs ?? 0.0;
  double get _carbsEaten => _foodLog?.totalCarbs ?? 0.0;

  double get _fatGoal => _dietPlan?.fat ?? 0.0;
  double get _fatEaten => _foodLog?.totalFat ?? 0.0;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
              progress: _calorieProgress,
              size: 200,
              strokeWidth: 16,
              child: Column(
                children: [
                  Text(
                    '${_remainingCalories.toInt()}',
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
                      '${_eatenCalories.toInt()}',
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
                      '${_goalCalories.toInt()}',
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
              eaten: _proteinEaten,
              goal: _proteinGoal,
              unit: 'g',
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildMacroCard(
              context,
              label: 'Carbs',
              eaten: _carbsEaten,
              goal: _carbsGoal,
              unit: 'g',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildMacroCard(
              context,
              label: 'Fat',
              eaten: _fatEaten,
              goal: _fatGoal,
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
                ).then((_) => _loadData()); // Reload after logging
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

