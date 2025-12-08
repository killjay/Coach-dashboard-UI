import '../utils/result.dart';
import 'workout_service.dart';
import 'diet_service.dart';
import 'metrics_service.dart';
import 'firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplianceService {
  final WorkoutService _workoutService = WorkoutService();
  final DietService _dietService = DietService();
  final MetricsService _metricsService = MetricsService();
  final FirestoreService _firestoreService = FirestoreService();

  /// Calculate daily compliance for a specific date
  /// Returns: Overall compliance score (0-100)
  /// Weights: Workout 50%, Nutrition 30%, Other metrics 20%
  Future<Result<double>> calculateDailyCompliance(String clientId, DateTime date) async {
    try {
      double workoutScore = 0.0;
      double nutritionScore = 0.0;
      double otherMetricsScore = 0.0;

      // 1. Workout Compliance (50% weight)
      final workoutResult = await _workoutService.getAssignedWorkoutForDate(clientId, date);
      if (workoutResult.isSuccess && workoutResult.dataOrNull != null) {
        final workoutLogResult = await _workoutService.getWorkoutLogForDate(clientId, date);
        if (workoutLogResult.isSuccess && 
            workoutLogResult.dataOrNull != null && 
            workoutLogResult.dataOrNull!.completed) {
          workoutScore = 1.0; // 100% if workout completed
        }
      } else {
        // No workout assigned for this date, so workout compliance is neutral (0.5)
        workoutScore = 0.5;
      }

      // 2. Nutrition Compliance (30% weight)
      final assignedDietResult = await _dietService.getAssignedDiet(clientId);
      if (assignedDietResult.isSuccess && assignedDietResult.dataOrNull != null) {
        final assignedDiet = assignedDietResult.dataOrNull!;
        final dietPlanResult = await _dietService.getPlan(assignedDiet.planId);
        
        if (dietPlanResult.isSuccess && dietPlanResult.dataOrNull != null) {
          final dietPlan = dietPlanResult.dataOrNull!;
          final foodLogResult = await _dietService.getDailyMacros(clientId, date);
          
          if (foodLogResult.isSuccess && foodLogResult.dataOrNull != null) {
            final foodLog = foodLogResult.dataOrNull!;
            // Calculate compliance as actual / target, capped at 1.0
            nutritionScore = (foodLog.totalCalories / dietPlan.calories).clamp(0.0, 1.0);
          } else {
            nutritionScore = 0.0; // No food logged
          }
        } else {
          nutritionScore = 0.5; // No diet plan assigned
        }
      } else {
        nutritionScore = 0.5; // No diet assigned
      }

      // 3. Other Metrics (20% weight) - Water, Steps, Sleep
      double waterScore = 0.0;
      double stepsScore = 0.0;
      double sleepScore = 0.0;

      // Water compliance
      final waterLogResult = await _metricsService.getWaterLog(clientId, date);
      if (waterLogResult.isSuccess && waterLogResult.dataOrNull != null) {
        final waterLog = waterLogResult.dataOrNull!;
        waterScore = (waterLog.amount / waterLog.goal).clamp(0.0, 1.0);
      } else {
        waterScore = 0.0;
      }

      // Steps compliance
      final stepsLogResult = await _metricsService.getStepsLog(clientId, date);
      if (stepsLogResult.isSuccess && stepsLogResult.dataOrNull != null) {
        final stepsLog = stepsLogResult.dataOrNull!;
        stepsScore = (stepsLog.steps / stepsLog.goal).clamp(0.0, 1.0);
      } else {
        stepsScore = 0.0;
      }

      // Sleep compliance (simplified - just check if logged)
      final sleepLogResult = await _metricsService.getSleepLog(clientId, date);
      sleepScore = (sleepLogResult.isSuccess && sleepLogResult.dataOrNull != null) ? 1.0 : 0.0;

      // Average of other metrics
      otherMetricsScore = (waterScore + stepsScore + sleepScore) / 3.0;

      // Calculate weighted overall compliance
      final overallCompliance = (workoutScore * 0.5) + (nutritionScore * 0.3) + (otherMetricsScore * 0.2);
      
      return Success(overallCompliance * 100); // Convert to 0-100 scale
    } catch (e) {
      return Failure('Failed to calculate daily compliance: $e');
    }
  }

  /// Calculate weekly compliance
  /// Returns: Average of daily compliance scores for the week
  Future<Result<double>> calculateWeeklyCompliance(String clientId, DateTime weekStart) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 6));
      double totalCompliance = 0.0;
      int daysWithData = 0;

      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final dailyResult = await calculateDailyCompliance(clientId, date);
        
        if (dailyResult.isSuccess) {
          totalCompliance += dailyResult.dataOrNull ?? 0.0;
          daysWithData++;
        }
      }

      final weeklyAverage = daysWithData > 0 ? totalCompliance / daysWithData : 0.0;
      return Success(weeklyAverage);
    } catch (e) {
      return Failure('Failed to calculate weekly compliance: $e');
    }
  }

  /// Calculate overall client compliance across all categories
  /// Used in Compliance Dashboard
  Future<Result<double>> calculateClientCompliance(String clientId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      // Get workout compliance
      final assignedWorkouts = await _firestoreService.queryCollection(
        'assigned_workouts',
        whereField: 'clientId',
        whereValue: clientId,
      );
      
      final workoutLogs = await _firestoreService.queryCollection(
        'workout_logs',
        whereField: 'clientId',
        whereValue: clientId,
      );

      final recentWorkouts = assignedWorkouts.where((w) {
        final startDate = w['startDate'] is Timestamp
            ? (w['startDate'] as Timestamp).toDate()
            : DateTime.parse(w['startDate'].toString());
        return startDate.isAfter(thirtyDaysAgo);
      }).length;

      final completedWorkouts = workoutLogs.where((log) {
        final logDate = log['date'] is Timestamp
            ? (log['date'] as Timestamp).toDate()
            : DateTime.parse(log['date'].toString());
        return logDate.isAfter(thirtyDaysAgo) && log['completed'] == true;
      }).length;

      final workoutCompliance = recentWorkouts > 0 ? (completedWorkouts / recentWorkouts * 50) : 0.0;

      // Get nutrition compliance
      final assignedDietResult = await _dietService.getAssignedDiet(clientId);
      double nutritionCompliance = 0.0;
      
      if (assignedDietResult.isSuccess && assignedDietResult.dataOrNull != null) {
        final dietPlanResult = await _dietService.getPlan(assignedDietResult.dataOrNull!.planId);
        
        if (dietPlanResult.isSuccess && dietPlanResult.dataOrNull != null) {
          final dietPlan = dietPlanResult.dataOrNull!;
          final foodLogs = await _firestoreService.queryCollection(
            'food_logs',
            whereField: 'clientId',
            whereValue: clientId,
          );
          
          final recentFoodLogs = foodLogs.where((log) {
            final logDate = log['date'] is Timestamp
                ? (log['date'] as Timestamp).toDate()
                : DateTime.parse(log['date'].toString());
            return logDate.isAfter(thirtyDaysAgo);
          }).toList();

          if (recentFoodLogs.isNotEmpty) {
            double totalCompliance = 0.0;
            for (final log in recentFoodLogs) {
              final calories = log['totalCalories'] as double? ?? 0.0;
              final compliance = (calories / dietPlan.calories).clamp(0.0, 1.0);
              totalCompliance += compliance;
            }
            nutritionCompliance = (totalCompliance / recentFoodLogs.length) * 30;
          }
        }
      }

      // Get other metrics compliance (water, steps)
      final waterLogs = await _firestoreService.queryCollection(
        'water_logs',
        whereField: 'clientId',
        whereValue: clientId,
      );
      
      final stepsLogs = await _firestoreService.queryCollection(
        'steps_logs',
        whereField: 'clientId',
        whereValue: clientId,
      );

      final recentWaterLogs = waterLogs.where((log) {
        final logDate = log['date'] is Timestamp
            ? (log['date'] as Timestamp).toDate()
            : DateTime.parse(log['date'].toString());
        return logDate.isAfter(thirtyDaysAgo);
      }).toList();

      final recentStepsLogs = stepsLogs.where((log) {
        final logDate = log['date'] is Timestamp
            ? (log['date'] as Timestamp).toDate()
            : DateTime.parse(log['date'].toString());
        return logDate.isAfter(thirtyDaysAgo);
      }).toList();

      double waterCompliance = 0.0;
      if (recentWaterLogs.isNotEmpty) {
        double totalWaterCompliance = 0.0;
        for (final log in recentWaterLogs) {
          final amount = log['amount'] as double? ?? 0.0;
          final goal = log['goal'] as double? ?? 1.0;
          totalWaterCompliance += (amount / goal).clamp(0.0, 1.0);
        }
        waterCompliance = totalWaterCompliance / recentWaterLogs.length;
      }

      double stepsCompliance = 0.0;
      if (recentStepsLogs.isNotEmpty) {
        double totalStepsCompliance = 0.0;
        for (final log in recentStepsLogs) {
          final steps = log['steps'] as int? ?? 0;
          final goal = log['goal'] as int? ?? 1;
          totalStepsCompliance += (steps / goal).clamp(0.0, 1.0);
        }
        stepsCompliance = totalStepsCompliance / recentStepsLogs.length;
      }

      final otherMetricsCompliance = ((waterCompliance + stepsCompliance) / 2.0) * 20;

      // Overall compliance
      final overallCompliance = workoutCompliance + nutritionCompliance + otherMetricsCompliance;
      
      return Success(overallCompliance.clamp(0.0, 100.0));
    } catch (e) {
      return Failure('Failed to calculate client compliance: $e');
    }
  }
}

