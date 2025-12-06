import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/assigned_workout_model.dart';
import '../models/assigned_diet_model.dart';
import '../models/workout_log_model.dart';
import '../models/food_log_model.dart';
import '../models/body_metrics_model.dart';
import '../models/water_log_model.dart';
import '../models/sleep_log_model.dart';
import '../services/workout_service.dart';
import '../services/diet_service.dart';
import '../services/metrics_service.dart';

class ClientProvider with ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();
  final DietService _dietService = DietService();
  final MetricsService _metricsService = MetricsService();
  
  List<AssignedWorkoutModel> _assignedWorkouts = [];
  AssignedDietModel? _assignedDiet;
  List<WorkoutLogModel> _workoutLogs = [];
  FoodLogModel? _todayFoodLog;
  BodyMetricsModel? _latestMetrics;
  WaterLogModel? _todayWaterLog;
  SleepLogModel? _todaySleepLog;
  bool _isLoading = false;
  
  StreamSubscription? _workoutsSubscription;
  StreamSubscription? _dietSubscription;

  List<AssignedWorkoutModel> get assignedWorkouts => _assignedWorkouts;
  AssignedDietModel? get assignedDiet => _assignedDiet;
  List<WorkoutLogModel> get workoutLogs => _workoutLogs;
  FoodLogModel? get todayFoodLog => _todayFoodLog;
  BodyMetricsModel? get latestMetrics => _latestMetrics;
  WaterLogModel? get todayWaterLog => _todayWaterLog;
  SleepLogModel? get todaySleepLog => _todaySleepLog;
  bool get isLoading => _isLoading;

  /// Load today's view data
  Future<void> loadTodayView(String clientId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final today = DateTime.now();
      
      // Load assigned workouts
      final workoutsResult = await _workoutService.getAssignedWorkouts(clientId);
      if (workoutsResult.isSuccess) {
        _assignedWorkouts = workoutsResult.dataOrNull ?? [];
      }

      // Load assigned diet
      final dietResult = await _dietService.getAssignedDiet(clientId);
      if (dietResult.isSuccess) {
        _assignedDiet = dietResult.dataOrNull;
      }

      // Load today's food log
      final foodResult = await _dietService.getDailyMacros(clientId, today);
      if (foodResult.isSuccess) {
        _todayFoodLog = foodResult.dataOrNull;
      }

      // Load today's water log
      final waterResult = await _metricsService.getWaterLog(clientId, today);
      if (waterResult.isSuccess) {
        _todayWaterLog = waterResult.dataOrNull;
      }

      // Load today's sleep log
      final sleepResult = await _metricsService.getSleepLog(clientId, today);
      if (sleepResult.isSuccess) {
        _todaySleepLog = sleepResult.dataOrNull;
      }

      // Load latest metrics
      final metricsResult = await _metricsService.getLatestMetrics(clientId);
      if (metricsResult.isSuccess) {
        _latestMetrics = metricsResult.dataOrNull;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Subscribe to real-time updates
  void subscribeToUpdates(String clientId) {
    // Subscribe to workouts
    _workoutsSubscription?.cancel();
    _workoutsSubscription = _workoutService.streamAssignedWorkouts(clientId).listen((workouts) {
      _assignedWorkouts = workouts;
      notifyListeners();
    });

    // Subscribe to diet
    _dietSubscription?.cancel();
    _dietSubscription = _dietService.streamAssignedDiet(clientId).listen((diet) {
      _assignedDiet = diet;
      notifyListeners();
    });
  }

  /// Log workout
  Future<void> logWorkout(WorkoutLogModel log) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _workoutService.logWorkout(log);
      if (result.isSuccess) {
        _workoutLogs.insert(0, log);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Log food
  Future<void> logFood(FoodLogModel log) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _dietService.logFood(log);
      if (result.isSuccess) {
        _todayFoodLog = log;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Log metrics
  Future<void> logMetrics(BodyMetricsModel metrics) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _metricsService.logMetrics(metrics);
      if (result.isSuccess) {
        _latestMetrics = metrics;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Log water
  Future<void> logWater(WaterLogModel log) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _metricsService.logWater(log);
      if (result.isSuccess) {
        _todayWaterLog = log;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Log sleep
  Future<void> logSleep(SleepLogModel log) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _metricsService.logSleep(log);
      if (result.isSuccess) {
        _todaySleepLog = log;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _workoutsSubscription?.cancel();
    _dietSubscription?.cancel();
    super.dispose();
  }
}




