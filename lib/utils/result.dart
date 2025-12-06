/// Result pattern for handling success/error states
abstract class Result<T> {
  const Result();
  
  bool get isSuccess;
  bool get isFailure;
  T? get dataOrNull;
  String? get errorMessage;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
  
  @override
  bool get isSuccess => true;
  
  @override
  bool get isFailure => false;
  
  @override
  T? get dataOrNull => data;
  
  @override
  String? get errorMessage => null;
}

class Failure<T> extends Result<T> {
  final String message;
  final String? code;
  const Failure(this.message, [this.code]);
  
  @override
  bool get isSuccess => false;
  
  @override
  bool get isFailure => true;
  
  @override
  T? get dataOrNull => null;
  
  @override
  String? get errorMessage => message;
}

