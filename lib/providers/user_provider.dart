import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../models/client_model.dart';
import '../models/coach_model.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  
  UserModel? _currentUser;
  ClientModel? _currentClient;
  CoachModel? _currentCoach;
  bool _isLoading = false;
  StreamSubscription? _userSubscription;

  UserModel? get currentUser => _currentUser;
  ClientModel? get currentClient => _currentClient;
  CoachModel? get currentCoach => _currentCoach;
  bool get isLoading => _isLoading;

  /// Load user data
  Future<void> loadUser(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _userService.getUser(userId);
      if (result.isSuccess) {
        _currentUser = result.dataOrNull;
        
        // Load role-specific data
        if (_currentUser?.isClient == true) {
          await loadClient(userId);
        } else if (_currentUser?.isCoach == true) {
          await loadCoach(userId);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load client data
  Future<void> loadClient(String clientId) async {
    try {
      final result = await _userService.getClient(clientId);
      if (result.isSuccess) {
        _currentClient = result.dataOrNull;
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  /// Load coach data
  Future<void> loadCoach(String coachId) async {
    try {
      final result = await _userService.getCoach(coachId);
      if (result.isSuccess) {
        _currentCoach = result.dataOrNull;
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  /// Stream user data (real-time)
  void subscribeToUser(String userId) {
    _userSubscription?.cancel();
    _userSubscription = _userService.streamUser(userId).listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  /// Stream client data (real-time)
  void subscribeToClient(String clientId) {
    _userSubscription?.cancel();
    _userSubscription = _userService.streamClient(clientId).listen((client) {
      _currentClient = client;
      notifyListeners();
    });
  }

  /// Update user
  Future<void> updateUser(UserModel user) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _userService.updateUser(user);
      if (result.isSuccess) {
        _currentUser = user;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update client onboarding
  Future<void> updateClientOnboarding({
    required String clientId,
    required bool onboardingCompleted,
    Map<String, dynamic>? demographics,
    Map<String, dynamic>? healthData,
    Map<String, dynamic>? lifestyleGoals,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _userService.updateClientOnboarding(
        clientId,
        onboardingCompleted: onboardingCompleted,
        demographics: demographics,
        healthData: healthData,
        lifestyleGoals: lifestyleGoals,
      );

      if (result.isSuccess) {
        await loadClient(clientId);
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
    _userSubscription?.cancel();
    super.dispose();
  }
}




