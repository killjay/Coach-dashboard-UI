import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/client_model.dart';
import '../models/workout_template_model.dart';
import '../models/diet_plan_model.dart';
import '../services/user_service.dart';
import '../services/workout_service.dart';
import '../services/diet_service.dart';

class CoachProvider with ChangeNotifier {
  final UserService _userService = UserService();
  final WorkoutService _workoutService = WorkoutService();
  final DietService _dietService = DietService();
  
  List<ClientModel> _clients = [];
  ClientModel? _selectedClient;
  List<WorkoutTemplateModel> _workoutTemplates = [];
  List<DietPlanModel> _dietPlans = [];
  bool _isLoading = false;
  StreamSubscription? _clientsSubscription;

  List<ClientModel> get clients => _clients;
  ClientModel? get selectedClient => _selectedClient;
  List<WorkoutTemplateModel> get workoutTemplates => _workoutTemplates;
  List<DietPlanModel> get dietPlans => _dietPlans;
  bool get isLoading => _isLoading;

  /// Load clients for coach
  Future<void> loadClients(String coachId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _userService.getClientList(coachId);
      if (result.isSuccess) {
        _clients = result.dataOrNull ?? [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stream clients (real-time)
  void subscribeToClients(String coachId) {
    _clientsSubscription?.cancel();
    _clientsSubscription = _userService.streamClientList(coachId).listen((clients) {
      _clients = clients;
      notifyListeners();
    });
  }

  /// Select a client
  void selectClient(ClientModel? client) {
    _selectedClient = client;
    notifyListeners();
  }

  /// Load workout templates
  Future<void> loadWorkoutTemplates(String coachId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _workoutService.getTemplates(coachId);
      if (result.isSuccess) {
        _workoutTemplates = result.dataOrNull ?? [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create workout template
  Future<void> createTemplate(WorkoutTemplateModel template) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _workoutService.createTemplate(template);
      if (result.isSuccess) {
        _workoutTemplates.insert(0, template);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load diet plans
  Future<void> loadDietPlans(String coachId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _dietService.getPlans(coachId);
      if (result.isSuccess) {
        _dietPlans = result.dataOrNull ?? [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create diet plan
  Future<void> createDietPlan(DietPlanModel plan) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _dietService.createPlan(plan);
      if (result.isSuccess) {
        _dietPlans.insert(0, plan);
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
    _clientsSubscription?.cancel();
    super.dispose();
  }
}




