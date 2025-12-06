import 'package:firebase_auth/firebase_auth.dart';
import '../exceptions/app_exceptions.dart';
import '../utils/result.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  Future<Result<UserCredential>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Verify Firebase Auth is initialized
      if (_auth.app == null) {
        return Failure('Firebase Auth is not initialized. Please restart the app.');
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      if (userCredential.user != null) {
        try {
          await userCredential.user!.updateDisplayName(name);
          await userCredential.user!.reload();
        } catch (e) {
          // Display name update is optional, continue even if it fails
          print('Warning: Could not update display name: $e');
        }
      }

      return Success(userCredential);
    } on FirebaseAuthException catch (e) {
      return Failure(_getAuthErrorMessage(e));
    } catch (e, stackTrace) {
      print('Sign up error: $e');
      print('Stack trace: $stackTrace');
      
      // Check for platform channel errors
      final errorString = e.toString();
      if (errorString.contains('pigeon') || errorString.contains('platform_interface')) {
        return Failure(
          'Firebase Auth platform error. Please ensure:\n'
          '1. You are running on iOS, Android, or Web\n'
          '2. Firebase is properly configured for your platform\n'
          '3. Try restarting the app'
        );
      }
      
      return Failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<Result<UserCredential>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Verify Firebase Auth is initialized
      if (_auth.app == null) {
        return Failure('Firebase Auth is not initialized. Please restart the app.');
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Success(userCredential);
    } on FirebaseAuthException catch (e) {
      return Failure(_getAuthErrorMessage(e));
    } catch (e, stackTrace) {
      print('Sign in error: $e');
      print('Stack trace: $stackTrace');
      
      // Check for platform channel errors
      final errorString = e.toString();
      if (errorString.contains('pigeon') || errorString.contains('platform_interface')) {
        return Failure(
          'Firebase Auth platform error. Please ensure:\n'
          '1. You are running on iOS, Android, or Web\n'
          '2. Firebase is properly configured for your platform\n'
          '3. Try restarting the app'
        );
      }
      
      return Failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign out
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e) {
      return Failure('Failed to sign out: $e');
    }
  }

  /// Reset password
  Future<Result<void>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Success(null);
    } on FirebaseAuthException catch (e) {
      return Failure(_getAuthErrorMessage(e));
    } catch (e) {
      return Failure('An unexpected error occurred: $e');
    }
  }

  /// Get error message from Firebase Auth exception
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return 'An account already exists for that email. Please sign in instead.';
      case 'user-not-found':
        return 'No user found for that email. Please check your email or sign up first.';
      case 'wrong-password':
        return 'Wrong password provided. Please check your password and try again.';
      case 'invalid-email':
        return 'The email address is invalid. Please enter a valid email address.';
      case 'user-disabled':
        return 'This user account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/Password authentication is not enabled in Firebase Console.\n\n'
            'To fix this:\n'
            '1. Go to Firebase Console (https://console.firebase.google.com/)\n'
            '2. Select your project: coach-dashboard-1\n'
            '3. Go to Authentication → Sign-in method\n'
            '4. Enable "Email/Password" provider\n'
            '5. Save and try again';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials and try again.';
      default:
        return e.message ?? 'An authentication error occurred: ${e.code}';
    }
  }
}
