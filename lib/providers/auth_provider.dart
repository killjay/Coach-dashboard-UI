import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/result.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      _user = user;
      _errorMessage = null;
      notifyListeners();
    });
    
    // Initialize with current user
    _user = _authService.currentUser;
  }

  /// Sign up with email and password
  Future<Result<User>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (result.isSuccess) {
        _user = result.dataOrNull?.user;
        _isLoading = false;
        notifyListeners();
        return Success(_user!);
      } else {
        _errorMessage = result.errorMessage;
        _isLoading = false;
        notifyListeners();
        return Failure(_errorMessage!);
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return Failure(_errorMessage!);
    }
  }

  /// Sign in with email and password
  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      if (result.isSuccess) {
        _user = result.dataOrNull?.user;
        _isLoading = false;
        notifyListeners();
        return Success(_user!);
      } else {
        _errorMessage = result.errorMessage;
        _isLoading = false;
        notifyListeners();
        return Failure(_errorMessage!);
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return Failure(_errorMessage!);
    }
  }

  /// Sign out
  Future<Result<void>> signOut() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.signOut();
      
      if (result.isSuccess) {
        _user = null;
        _isLoading = false;
        notifyListeners();
        return const Success(null);
      } else {
        _errorMessage = result.errorMessage;
        _isLoading = false;
        notifyListeners();
        return Failure(_errorMessage!);
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return Failure(_errorMessage!);
    }
  }

  /// Reset password
  Future<Result<void>> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.resetPassword(email);
      
      _isLoading = false;
      if (result.isSuccess) {
        notifyListeners();
        return const Success(null);
      } else {
        _errorMessage = result.errorMessage;
        notifyListeners();
        return Failure(_errorMessage!);
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return Failure(_errorMessage!);
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
