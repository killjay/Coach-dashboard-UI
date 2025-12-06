/// Base exception class for app-specific errors
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Firebase Firestore related exceptions
class FirestoreException extends AppException {
  FirestoreException(super.message, [super.code]);
}

/// Firebase Authentication related exceptions
class AuthException extends AppException {
  AuthException(super.message, [super.code]);
}

/// Firebase Storage related exceptions
class StorageException extends AppException {
  StorageException(super.message, [super.code]);
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException(super.message, [super.code]);
}

/// Validation related exceptions
class ValidationException extends AppException {
  ValidationException(super.message, [super.code]);
}




