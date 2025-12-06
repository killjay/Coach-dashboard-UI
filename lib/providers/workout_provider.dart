import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/workout_template_model.dart';
import '../models/assigned_workout_model.dart';
import '../models/workout_log_model.dart';
import '../services/workout_service.dart';

class WorkoutProvider with ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();
  
  List<WorkoutTemplateModel> _templates = [];
  List<AssignedWorkoutModel> _assignedWorkouts = [];
  WorkoutLogModel? _currentWorkout;
  bool _isLoading = false;
  StreamSubscription? _workoutsSubscription;

  List<WorkoutTemplateModel> get templates => _templates;
  List<AssignedWorkoutModel> get assignedWorkouts => _assignedWorkouts;
  WorkoutLogModel? get currentWorkout => _currentWorkout;
  bool get isLoading => _isLoading;

  /// Load templates
  Future<void> loadTemplates(String coachId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _workoutService.getTemplates(coachId);
      if (result.isSuccess) {
        _templates = result.dataOrNull ?? [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create template
  Future<void> createTemplate(WorkoutTemplateModel template) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _workoutService.createTemplate(template);
      if (result.isSuccess) {
        _templates.insert(0, template);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Assign workout
  Future<void> assignWorkout(AssignedWorkoutModel assignment) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _workoutService.assignWorkout(assignment);
      if (result.isSuccess) {
        _assignedWorkouts.add(assignment);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load assigned workouts
  Future<void> loadAssignedWorkouts(String clientId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _workoutService.getAssignedWorkouts(clientId);
      if (result.isSuccess) {
        _assignedWorkouts = result.dataOrNull ?? [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Subscribe to assigned workouts (real-time)
  void subscribeToWorkouts(String clientId) {
    _workoutsSubscription?.cancel();
    _workoutsSubscription = _workoutService.streamAssignedWorkouts(clientId).listen((workouts) {
      _assignedWorkouts = workouts;
      notifyListeners();
    });
  }

  /// Set current workout being logged
  void setCurrentWorkout(WorkoutLogModel? workout) {
    _currentWorkout = workout;
    notifyListeners();
  }

  /// Log workout
  Future<void> logWorkout(WorkoutLogModel log) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _workoutService.logWorkout(log);
      if (result.isSuccess) {
        _currentWorkout = null;
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
    super.dispose();
  }
}




