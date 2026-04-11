/// Domain-layer failure representations.
///
/// Repositories catch [Exception]s from the data layer and return
/// [Failure] instances so the presentation layer never deals with
/// raw exceptions.
sealed class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// A failure originating from a remote server / API.
final class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required String message,
    this.statusCode,
  }) : super(message);
}

/// A failure originating from local cache operations.
final class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message);
}

/// A failure due to missing network connectivity.
final class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'No internet connection',
  }) : super(message);
}

/// A failure originating from an authentication operation.
final class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message);

  static const invalidCredentials =
      AuthFailure(message: 'Invalid email or password.');
  static const userNotFound =
      AuthFailure(message: 'No account found with this email.');
  static const emailAlreadyInUse =
      AuthFailure(message: 'An account with this email already exists.');
  static const weakPassword =
      AuthFailure(message: 'Password must be at least 6 characters.');
  static const unknown =
      AuthFailure(message: 'An unknown error occurred. Please try again.');
}
