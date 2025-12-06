import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/diet_plan_model.dart';
import '../models/assigned_diet_model.dart';
import '../models/food_log_model.dart';
import '../services/diet_service.dart';

class DietProvider with ChangeNotifier {
  final DietService _dietService = DietService();
  
  List<DietPlanModel> _plans = [];
  AssignedDietModel? _assignedDiet;
  List<FoodLogModel> _dailyLogs = [];
  bool _isLoading = false;
  StreamSubscription? _dietSubscription;

  List<DietPlanModel> get plans => _plans;
  AssignedDietModel? get assignedDiet => _assignedDiet;
  List<FoodLogModel> get dailyLogs => _dailyLogs;
  bool get isLoading => _isLoading;

  /// Load plans
  Future<void> loadPlans(String coachId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _dietService.getPlans(coachId);
      if (result.isSuccess) {
        _plans = result.dataOrNull ?? [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create plan
  Future<void> createPlan(DietPlanModel plan) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _dietService.createPlan(plan);
      if (result.isSuccess) {
        _plans.insert(0, plan);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Assign diet
  Future<void> assignDiet(AssignedDietModel assignment) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _dietService.assignDiet(assignment);
      if (result.isSuccess) {
        _assignedDiet = assignment;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load assigned diet
  Future<void> loadAssignedDiet(String clientId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _dietService.getAssignedDiet(clientId);
      if (result.isSuccess) {
        _assignedDiet = result.dataOrNull;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Subscribe to assigned diet (real-time)
  void subscribeToDiet(String clientId) {
    _dietSubscription?.cancel();
    _dietSubscription = _dietService.streamAssignedDiet(clientId).listen((diet) {
      _assignedDiet = diet;
      notifyListeners();
    });
  }

  /// Log food
  Future<void> logFood(FoodLogModel log) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _dietService.logFood(log);
      if (result.isSuccess) {
        _dailyLogs.insert(0, log);
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
    _dietSubscription?.cancel();
    super.dispose();
  }
}




