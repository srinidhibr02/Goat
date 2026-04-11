/// Thrown when an API / server request fails.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Thrown when a local cache operation fails.
class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when the device has no network connectivity.
class NetworkException implements Exception {
  final String message;

  const NetworkException({
    this.message = 'No internet connection',
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when a Firebase Auth / mock-auth operation fails.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  static const invalidCredentials =
      AuthException('Invalid email or password.');
  static const userNotFound =
      AuthException('No account found with this email.');
  static const emailAlreadyInUse =
      AuthException('An account with this email already exists.');
  static const weakPassword =
      AuthException('Password must be at least 6 characters.');
  static const operationNotAllowed =
      AuthException('This sign-in method is not enabled.');
  static const unknown =
      AuthException('An unknown error occurred. Please try again.');

  @override
  String toString() => 'AuthException: $message';
}
