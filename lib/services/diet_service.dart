import '../models/diet_plan_model.dart';
import '../models/assigned_diet_model.dart';
import '../models/food_log_model.dart';
import '../exceptions/app_exceptions.dart';
import '../utils/result.dart';
import 'firestore_service.dart';

class DietService {
  final FirestoreService _firestoreService = FirestoreService();

  /// Create diet plan
  Future<Result<DietPlanModel>> createPlan(DietPlanModel plan) async {
    try {
      await _firestoreService.setDocument(
        'diet_plans/${plan.id}',
        plan.toJson(),
      );
      return Success(plan);
    } catch (e) {
      return Failure('Failed to create diet plan: $e');
    }
  }

  /// Get plans by coach
  Future<Result<List<DietPlanModel>>> getPlans(String coachId) async {
    try {
      final dataList = await _firestoreService.queryCollection(
        'diet_plans',
        whereField: 'createdBy',
        whereValue: coachId,
        orderBy: 'createdAt',
        descending: true,
      );
      final plans = dataList.map((data) => DietPlanModel.fromJson(data)).toList();
      return Success(plans);
    } catch (e) {
      return Failure('Failed to get diet plans: $e');
    }
  }

  /// Get plan by ID
  Future<Result<DietPlanModel>> getPlan(String planId) async {
    try {
      final data = await _firestoreService.getDocument('diet_plans/$planId');
      if (data == null) {
        return const Failure('Diet plan not found');
      }
      return Success(DietPlanModel.fromJson(data));
    } catch (e) {
      return Failure('Failed to get diet plan: $e');
    }
  }

  /// Assign diet to client
  Future<Result<void>> assignDiet(AssignedDietModel assignment) async {
    try {
      await _firestoreService.setDocument(
        'assigned_diets/${assignment.id}',
        assignment.toJson(),
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to assign diet: $e');
    }
  }

  /// Get assigned diet for client
  Future<Result<AssignedDietModel?>> getAssignedDiet(String clientId) async {
    try {
      final dataList = await _firestoreService.queryCollection(
        'assigned_diets',
        whereField: 'clientId',
        whereValue: clientId,
        orderBy: 'startDate',
        descending: true,
        limit: 1,
      );
      
      if (dataList.isEmpty) {
        return const Success(null);
      }
      
      return Success(AssignedDietModel.fromJson(dataList.first));
    } catch (e) {
      return Failure('Failed to get assigned diet: $e');
    }
  }

  /// Stream assigned diet (real-time)
  Stream<AssignedDietModel?> streamAssignedDiet(String clientId) {
    return _firestoreService.streamQuery(
      'assigned_diets',
      whereField: 'clientId',
      whereValue: clientId,
      orderBy: 'startDate',
      descending: true,
      limit: 1,
    ).map((dataList) {
      return dataList.isEmpty ? null : AssignedDietModel.fromJson(dataList.first);
    });
  }

  /// Log food
  Future<Result<FoodLogModel>> logFood(FoodLogModel log) async {
    try {
      await _firestoreService.setDocument(
        'food_logs/${log.id}',
        log.toJson(),
      );
      return Success(log);
    } catch (e) {
      return Failure('Failed to log food: $e');
    }
  }

  /// Get daily macros for a date
  Future<Result<FoodLogModel?>> getDailyMacros(String clientId, DateTime date) async {
    try {
      // Get logs for the specific date
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final dataList = await _firestoreService.queryCollection(
        'food_logs',
        whereField: 'clientId',
        whereValue: clientId,
      );
      
      final logs = dataList.map((data) => FoodLogModel.fromJson(data)).toList();
      final dayLog = logs.firstWhere(
        (log) => log.date.isAfter(startOfDay) && log.date.isBefore(endOfDay),
        orElse: () => throw StateError('No log found'),
      );
      
      return Success(dayLog);
    } catch (e) {
      return Success(null); // No log for this day
    }
  }

  /// Get diet history
  Future<Result<List<FoodLogModel>>> getDietHistory(
    String clientId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final dataList = await _firestoreService.queryCollection(
        'food_logs',
        whereField: 'clientId',
        whereValue: clientId,
        orderBy: 'date',
        descending: true,
      );
      
      var logs = dataList.map((data) => FoodLogModel.fromJson(data)).toList();
      
      if (startDate != null) {
        logs = logs.where((log) => 
          log.date.isAfter(startDate.subtract(const Duration(days: 1))) || 
          log.date.isAtSameMomentAs(startDate)
        ).toList();
      }
      if (endDate != null) {
        logs = logs.where((log) => 
          log.date.isBefore(endDate.add(const Duration(days: 1))) || 
          log.date.isAtSameMomentAs(endDate)
        ).toList();
      }

      return Success(logs);
    } catch (e) {
      return Failure('Failed to get diet history: $e');
    }
  }

  /// Stream food logs (real-time)
  Stream<List<FoodLogModel>> streamFoodLogs(String clientId) {
    return _firestoreService.streamQuery(
      'food_logs',
      whereField: 'clientId',
      whereValue: clientId,
      orderBy: 'date',
      descending: true,
    ).map((dataList) {
      return dataList.map((data) => FoodLogModel.fromJson(data)).toList();
    });
  }

  /// Get or create daily food log
  Future<Result<FoodLogModel>> getOrCreateDailyFoodLog(String clientId, DateTime date) async {
    try {
      final logResult = await getDailyMacros(clientId, date);
      final existingLog = logResult.dataOrNull;
      
      if (existingLog != null) {
        return Success(existingLog);
      }
      
      // Create new log
      final newLog = FoodLogModel(
        id: _firestoreService.generateId('food_logs'),
        clientId: clientId,
        date: date,
        meals: [],
        totalCalories: 0.0,
        totalProtein: 0.0,
        totalCarbs: 0.0,
        totalFat: 0.0,
        loggedAt: DateTime.now(),
      );
      
      return Success(newLog);
    } catch (e) {
      return Failure('Failed to get or create food log: $e');
    }
  }

  /// Add meal to existing log
  Future<Result<FoodLogModel>> addMealToLog(String clientId, DateTime date, MealModel meal) async {
    try {
      final logResult = await getOrCreateDailyFoodLog(clientId, date);
      final foodLog = logResult.dataOrNull;
      
      if (foodLog == null) {
        return const Failure('Failed to get or create food log');
      }
      
      // Add meal to list
      final updatedMeals = [...foodLog.meals, meal];
      
      // Recalculate totals
      final totalCalories = updatedMeals.fold<double>(0.0, (sum, m) => sum + m.calories);
      final totalProtein = updatedMeals.fold<double>(0.0, (sum, m) => sum + m.protein);
      final totalCarbs = updatedMeals.fold<double>(0.0, (sum, m) => sum + m.carbs);
      final totalFat = updatedMeals.fold<double>(0.0, (sum, m) => sum + m.fat);
      
      // Create updated log
      final updatedLog = FoodLogModel(
        id: foodLog.id,
        clientId: foodLog.clientId,
        date: foodLog.date,
        meals: updatedMeals,
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
        loggedAt: DateTime.now(),
      );
      
      // Save to Firestore
      return await logFood(updatedLog);
    } catch (e) {
      return Failure('Failed to add meal to log: $e');
    }
  }
}

